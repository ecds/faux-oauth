# frozen_string_literal: true

#
# Service for authentication flow.
#
module ShibbolethService
  class << self
    def authenticate(auth_hash)
      Rails.logger.debug "request.env['omniauth.auth']: #{auth_hash.inspect}"
      {
        provider: auth_hash[:provider],
        email: auth_hash[:info][:email],
        uid: Digest::SHA1.hexdigest(auth_hash[:uid].to_s)
      }
    end
  end
end
