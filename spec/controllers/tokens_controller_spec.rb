# rubocop:disable Style/GlobalVars, Metrics/BlockLength

require 'rails_helper'
require 'json'

RSpec.describe TokensController, type: :controller do
  before do
    create(:client)
  end

  let(:valid_session) { {} }

  # describe 'Shibboleth POST #create' do
  #   before do
  #     request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:shibboleth]
  #     puts OmniAuth.config.mock_auth[:shibboleth]
  #   end

  #   context 'with valid params' do
  #     it 'renders a JSON response with the new token' do
  #       post :create, params: { provider: :shibboleth }, session: valid_session

  #       # TODO: probably best not to set a global var like this. But right off,
  #       # I'm not sure of another way to set this for the token.
  #       $token = assigns(:auth_response)
  #       expect(response).to redirect_to("https://emory.edu/redirect.html?#{$token.to_query}")
  #     end

  #     it 'validates token' do
  #       get :verify, params: $token
  #       expect(JSON.parse(response.body)[0]['data']['email']).to eq('karl@marx.org')
  #     end

  #     it 'fails when token is expired' do
  #       puts "" # cause new line
  #       puts "sleeping for 30 seconds to let the token expire."
  #       sleep(30)
  #       get :verify, params: $token
  #       expect(JSON.parse(response.body)['message']).to eq('Token has expired')
  #     end
  #   end

  #   # context 'with invalid params' do
  #   #   it 'renders a JSON response with errors for the new token' do
  #   #     invalid_attributes = {}
  #   #     post :create,
  #   #          params: { token: invalid_attributes },
  #   #          session: valid_session
  #   #     expect(response).to have_http_status(:unprocessable_entity)
  #   #     expect(response.content_type).to eq('application/json')
  #   #   end
  #   # end
  # end

  describe 'Google OAuth2 POST #create' do
  context 'with valid params' do
    before do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
    end
      it 'renders a JSON response with the new token' do
        post :create, params: { provider: :google_oauth2 }, session: valid_session

        # TODO: probably best not to set a global var like this. But right off,
        # I'm not sure of another way to set this for the token.
        $token = assigns(:auth_response)
        expect(response).to redirect_to("https://emory.edu/redirect.html?#{$token.to_query}")
      end

      it 'validates token' do
        get :verify, params: $token
        puts response.body
        expect(JSON.parse(response.body)[0]['data']['who']).to eq('karlmarx@gmail.com')
      end

      it 'fails when token is expired' do
        puts "" # cause new line
        puts "sleeping for 30 seconds to let the token expire."
        sleep(30)
        get :verify, params: $token
        expect(JSON.parse(response.body)['message']).to eq('Token has expired')
      end
    end

    # context 'with invalid params' do
    #   it 'renders a JSON response with errors for the new token' do
    #     invalid_attributes = {}
    #     post :create,
    #          params: { token: invalid_attributes },
    #          session: valid_session
    #     expect(response).to have_http_status(:unprocessable_entity)
    #     expect(response.content_type).to eq('application/json')
    #   end
    # end
  end
end
