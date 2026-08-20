# frozen_string_literal: true

require "jwt"

#
# <Description>
#
module TokenService
  class << self
    #
    # <Description>
    #
    # @param [<Type>] session <description>
    # @param [<Type>] client <description>
    #
    # @return [<Type>] <description>
    #
    def create(session)
      exp = 30.seconds.from_now.to_i
      exp_payload = { data: session, exp: exp }
      token = JWT.encode exp_payload, secret, "HS256"
      { access_token: token, token_type: "bearer" }
    end

    #
    # <Description>
    #
    # @param [<Type>] token <description>
    #
    # @return [<Type>] <description>
    #
    def verify(token)
      JWT.decode token, secret, true, algorithm: "HS256"
    rescue JWT::ExpiredSignature
      { message: "Token has expired" }
    rescue JWT::DecodeError
      { message: "Token is invalid" }
    end

    private

    # A secret dedicated to signing these tokens, kept separate from
    # secret_key_base (which also signs Rails' own cookies/sessions), so it
    # can be rotated on its own without touching config/credentials.yml.enc
    # or the OAuth secrets/db password stored there.
    #
    # Tokens are only ever valid for 30 seconds, so a rotation only affects
    # whatever token happened to be mid-flight at that moment.
    def secret
      return ENV.fetch("JWT_SECRET") if Rails.env.production?

      ENV.fetch("JWT_SECRET", Rails.application.credentials[:secret_key_base])
    end
  end
end
