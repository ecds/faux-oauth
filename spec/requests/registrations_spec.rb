require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  describe 'POST /register' do
    it 'creates an unconfirmed user and generates a confirmation token' do
      expect {
        post register_path, params: {
          user: { email: 'new@example.com', password: 'a very long password', password_confirmation: 'a very long password' }
        }
      }.to change(User, :count).by(1)

      user = User.last
      expect(user.confirmed?).to be false
      expect(user.confirmation_token).to be_present
      expect(response).to have_http_status(:ok)

      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(ActionMailer::Base.deliveries.last.to).to eq([ user.email ])
    end

    it 'still succeeds if mail delivery fails, so a transient SES issue does not 500 signup' do
      allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now).and_raise(Net::SMTPFatalError.new('boom'))

      post register_path, params: {
        user: { email: 'mailfail@example.com', password: 'a very long password', password_confirmation: 'a very long password' }
      }

      expect(response).to have_http_status(:ok)
      expect(User.exists?(email: 'mailfail@example.com')).to be true
    end

    it 'rejects invalid params' do
      post register_path, params: {
        user: { email: 'not-an-email', password: 'short', password_confirmation: 'short' }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(User.count).to eq(0)
    end

    it 'rate limits repeated registrations' do
      5.times do |n|
        post register_path, params: {
          user: { email: "flood#{n}@example.com", password: 'a very long password', password_confirmation: 'a very long password' }
        }
      end
      post register_path, params: {
        user: { email: 'oneflood@example.com', password: 'a very long password', password_confirmation: 'a very long password' }
      }

      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
