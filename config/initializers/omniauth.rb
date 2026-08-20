Rails.application.config.middleware.use OmniAuth::Builder do
  #  provider :shibboleth,
  #           uid_field: 'eduPersonPrincipalName',
  #           info_fields: {
  #             email: 'eduPersonPrincipalName'
  #           }

  #  provider :saml,
  #           idp_sso_target_url: '/Shibboleth.sso/Login'

  provider :google_oauth2,
           Rails.application.credentials.google_auth[:key],
           Rails.application.credentials.google_auth[:secret],
           {
             scope: "email,profile",
             prompt: "select_account",
             image_aspect_ratio: "square",
             image_size: 50
            }

  provider :github,
           Rails.application.credentials.github_auth[:key],
           Rails.application.credentials.github_auth[:secret]
end

OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = [ :post, :get ]
OmniAuth.config.silence_get_warning = true
