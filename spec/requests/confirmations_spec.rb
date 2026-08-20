require 'rails_helper'

RSpec.describe 'Confirmations', type: :request do
  describe 'GET /confirm/:token' do
    it 'confirms a user with a valid token' do
      user = create(:user)
      user.generate_confirmation_token!

      get confirm_path(token: user.confirmation_token)

      expect(response).to have_http_status(:ok)
      expect(user.reload.confirmed?).to be true
    end

    it 'rejects an unknown token' do
      get confirm_path(token: 'not-a-real-token')

      expect(response).to have_http_status(:not_found)
    end
  end
end
