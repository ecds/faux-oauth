class TokensController < ActionController::Base
  include ActionController::Cookies
  skip_before_action :verify_authenticity_token
  before_action :set_token, only: [:show, :update, :destroy]
  before_action :authenticate, only: [:create]

  # GET /tokens
  def index
    @tokens = Token.all

    render json: @tokens
  end

  # GET /tokens?access_token=abcdefghijklmnopqrstuvwxyz
  def verify
    Rails.logger.debug "cookies: #{cookies.methods}"
    render json: TokenService.verify(params[:access_token])
  end

  # POST /tokens
  def create
    # Rails.logger.debug "auth!!!!!! = #{request.env['omniauth.auth'].inspect}"
    # @session = authenticate(auth_hash)
    Rails.logger.debug "auth_hash: #{@session.inspect}"
    # FIXME: ATM it doesn't seem like the `omniauth.origin` can be set in
    # the mock. There is an open WIP PR https://github.com/omniauth/omniauth/issues/934
    if Rails.env.test?
      @client = Client.find_or_create_by(redirect_uri: 'https://emory.edu/redirect.html')
    else
      @client = Client.find_by(
        host: URI.parse(request.env['omniauth.origin']).host
      )
    end
    @auth_response = TokenService.create(@session)

    if @auth_response
      redirect_to generate_url(
        @client.redirect_uri, @auth_response
      )
    else
      render json: @token.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tokens/1
  def update
    if @token.update(token_params)
      render json: @token
    else
      render json: @token.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tokens/1
  def destroy
    Rails.logger.debug
    cookies.clear
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_token
    @token = Token.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def token_params
    params.fetch(:token, {})
  end

  def generate_url(url, params = {})
    uri = URI(url)
    uri.query = params.to_query
    uri.to_s
  end

  #
  # Extracts the user information returned by Omniauth provider.
  #
  # @return [Hash] Hash of user attributes whith symbolized keys. 
  #
  def auth_hash
    request.env['omniauth.auth'].symbolize_keys!
  end

  # def get_user(hash)
  #   case hash[:provider]
  #   when 'shibboleth'
  #     ShibbolethService.authenticate(hash)
  #   when 'google_oauth2'
  #     GoogleOauth2Service.authenticate(hash)
  #   end
  # end

  def authenticate()
    hash = request.env['omniauth.auth'].symbolize_keys!
    Rails.logger.debug "request.env['omniauth.auth']: #{hash.inspect}"
    @session = {
      provider: hash[:provider],
      email: hash[:info][:email],
      uid: Digest::SHA1.hexdigest(hash[:uid].to_s)
    }
  end
end
