# frozen_string_literal: true

require 'jwt'

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
      token = JWT.encode exp_payload,
                         Rails.application.credentials[:secret_key_base],
                         'HS256'
      { access_token: token, token_type: 'bearer' }
    end

    #
    # <Description>
    #
    # @param [<Type>] token <description>
    #
    # @return [<Type>] <description>
    #
    def verify(token)
      begin
        decoded_token = JWT.decode token, Rails.application.credentials[:secret_key_base], true, algorithm: 'HS256'
      rescue JWT::ExpiredSignature
        # Handle expired token, e.g. logout user or deny access
        return { message: 'Token has expired' }
      end
      decoded_token
    end
  end
end
