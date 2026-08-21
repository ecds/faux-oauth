require 'rails_helper'

RSpec.describe 'Confirmations', type: :request do
  describe 'GET /confirm/:token' do
    it 'confirms a user with a valid token' do
      user = create(:user)
      client = create(:client)
      user.generate_confirmation_token!

      get confirm_path(token: user.confirmation_token, origin: client.redirect_uri)

      expect(response).to have_http_status(:redirect)
      expect(user.reload.confirmed?).to be true
    end

    it 'rejects an unknown token' do
      get confirm_path(token: 'not-a-real-token')

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /confirmation/resend' do
    it 'shows an error instead of the form when origin is missing' do
      get new_confirmation_path

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include('<form')
    end
  end

  describe 'POST /confirmation/resend' do
    it 'issues a fresh confirmation token for an unconfirmed account, replacing any old one' do
      user = create(:user)
      user.generate_confirmation_token!
      old_token = user.confirmation_token

      post new_confirmation_path, params: { email: user.email, origin: 'https://emory.edu' }

      expect(response).to have_http_status(:ok)
      expect(user.reload.confirmation_token).to be_present
      expect(user.confirmation_token).not_to eq(old_token)

      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(ActionMailer::Base.deliveries.last.to).to eq([ user.email ])
    end

    it 'does not resend for an already-confirmed account' do
      user = create(:user, :confirmed)

      post new_confirmation_path, params: { email: user.email, origin: 'https://emory.edu' }

      expect(response).to have_http_status(:ok)
      expect(user.reload.confirmation_token).to be_nil
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it 'responds the same way for an unknown email, to avoid leaking which emails have accounts' do
      post new_confirmation_path, params: { email: 'nobody@example.com', origin: 'https://emory.edu' }

      expect(response).to have_http_status(:ok)
    end
  end
end
