require 'rails_helper'

RSpec.describe 'Passwords', type: :request do
  describe 'POST /password/reset' do
    it 'issues a reset token for a known email' do
      user = create(:user, :confirmed)

      post new_password_path, params: { email: user.email }

      expect(response).to have_http_status(:ok)
      expect(user.reload.reset_password_token).to be_present
    end

    it 'responds the same way for an unknown email, to avoid leaking which emails have accounts' do
      post new_password_path, params: { email: 'nobody@example.com' }

      expect(response).to have_http_status(:ok)
    end

    it 'rate limits repeated requests' do
      user = create(:user, :confirmed)

      5.times { post new_password_path, params: { email: user.email } }
      post new_password_path, params: { email: user.email }

      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe 'PATCH /password/reset/:token' do
    it 'updates the password with a valid token' do
      user = create(:user, :confirmed)
      user.generate_reset_password_token!

      patch password_path(token: user.reset_password_token),
            params: { password: 'a brand new password', password_confirmation: 'a brand new password' }

      expect(response).to have_http_status(:ok)
      expect(user.reload.authenticate('a brand new password')).to be_truthy
      expect(user.reset_password_token).to be_nil
    end

    it 'rejects an expired token' do
      user = create(:user, :confirmed)
      user.generate_reset_password_token!
      user.update!(reset_password_sent_at: 3.hours.ago)

      patch password_path(token: user.reset_password_token),
            params: { password: 'a brand new password', password_confirmation: 'a brand new password' }

      expect(response).to have_http_status(:not_found)
    end
  end
end
