# frozen_string_literal: true

require 'jwt'

#
# Service for authentication flow.
#
module GoogleOauth2Service
  class << self
    def authenticate(auth_hash)
      Rails.logger.debug "request.env['omniauth.auth']????: #{auth_hash.inspect}"
      {
        provider: auth_hash[:provider],
        email: auth_hash[:info][:email],
        uid: Digest::SHA1.hexdigest(auth_hash[:uid].to_s)
      }
    end

    private

    #
    # Extracts the user information returned by Omniauth provider.
    #
    # @return [Hash] Hash of user attributes whith symbolized keys. 
    #
    def auth_hash
      request.env['omniauth.auth'].symbolize_keys!
    end
  end
end
