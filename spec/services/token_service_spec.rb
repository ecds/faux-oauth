require 'rails_helper'

RSpec.describe TokenService do
  describe '.create / .verify' do
    it 'round-trips a session hash' do
      auth_response = TokenService.create(who: 'karl@marx.org')
      decoded = TokenService.verify(auth_response[:access_token])

      expect(decoded[0]['data']).to eq('who' => 'karl@marx.org')
    end

    it 'rejects an expired token with a clean message, not a crash' do
      expired_token = JWT.encode(
        { data: { who: 'karl@marx.org' }, exp: 1.hour.ago.to_i },
        Rails.application.credentials[:secret_key_base],
        'HS256'
      )

      expect(TokenService.verify(expired_token)).to eq(message: 'Token has expired')
    end

    it 'rejects a token signed with a different secret, instead of raising' do
      forged_token = JWT.encode(
        { data: { who: 'karl@marx.org' }, exp: 30.seconds.from_now.to_i },
        'not-the-real-secret',
        'HS256'
      )

      expect(TokenService.verify(forged_token)).to eq(message: 'Token is invalid')
    end

    it 'rejects a garbage string, instead of raising' do
      expect(TokenService.verify('not-a-jwt-at-all')).to eq(message: 'Token is invalid')
    end
  end

  describe 'the signing secret' do
    it 'prefers JWT_SECRET over secret_key_base when set' do
      original = ENV['JWT_SECRET']
      ENV['JWT_SECRET'] = 'a-dedicated-jwt-secret'

      begin
        token = TokenService.create(who: 'karl@marx.org')[:access_token]

        expect { JWT.decode(token, Rails.application.credentials[:secret_key_base], true, algorithm: 'HS256') }
          .to raise_error(JWT::VerificationError)
        expect(JWT.decode(token, 'a-dedicated-jwt-secret', true, algorithm: 'HS256')[0]['data']).to eq('who' => 'karl@marx.org')
      ensure
        ENV['JWT_SECRET'] = original
      end
    end
  end
end
