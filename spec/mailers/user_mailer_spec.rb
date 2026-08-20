require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#confirmation_instructions' do
    it 'links to the confirm path with the token and origin' do
      user = create(:user)
      user.generate_confirmation_token!

      mail = UserMailer.confirmation_instructions(user, 'https://emory.edu')

      expect(mail.to).to eq([ user.email ])
      expect(mail.body.encoded).to include(user.confirmation_token)
      expect(mail.body.encoded).to include('origin=https')
    end
  end

  describe '#reset_password_instructions' do
    it 'links to the edit password path with the token' do
      user = create(:user, :confirmed)
      user.generate_reset_password_token!

      mail = UserMailer.reset_password_instructions(user, 'https://emory.edu')

      expect(mail.to).to eq([ user.email ])
      expect(mail.body.encoded).to include(user.reset_password_token)
    end
  end
end
