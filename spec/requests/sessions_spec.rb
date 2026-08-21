require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /login' do
    it 'renders the login form when origin is present' do
      get login_path(origin: 'https://emory.edu')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('form')
    end

    it 'shows an error instead of the form when origin is missing' do
      get login_path

      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include('<form')
    end
  end

  describe 'POST /login' do
    it 'redirects to the client with a token for a confirmed user' do
      user = create(:user, :confirmed, email: 'karlmarx@gmail.com',
                    password: 'a very long password', password_confirmation: 'a very long password')

      post login_path, params: { email: user.email, password: 'a very long password', origin: 'https://emory.edu' }

      expect(response).to have_http_status(:found)
      expect(response.location).to start_with('https://emory.edu/redirect.html')
    end

    it 'rejects an unconfirmed user' do
      user = create(:user, password: 'a very long password', password_confirmation: 'a very long password')

      post login_path, params: { email: user.email, password: 'a very long password', origin: 'https://emory.edu' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'rejects a bad password' do
      user = create(:user, :confirmed, password: 'a very long password', password_confirmation: 'a very long password')

      post login_path, params: { email: user.email, password: 'wrong password entirely', origin: 'https://emory.edu' }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'rate limits repeated attempts' do
      user = create(:user, :confirmed, password: 'a very long password', password_confirmation: 'a very long password')

      10.times do
        post login_path, params: { email: user.email, password: 'wrong password entirely' }
      end
      post login_path, params: { email: user.email, password: 'wrong password entirely' }

      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
