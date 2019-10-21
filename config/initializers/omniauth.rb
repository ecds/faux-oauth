Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shibboleth,
           uid_field: 'eduPersonPrincipalName',
           info_fields: {
             email: 'eduPersonPrincipalName'
           }
  
  provider :google_oauth2,
           ENV['GOOGLE_CLIENT_ID'],
           ENV['GOOGLE_CLIENT_SECRET'],
           scope: 'email',
           prompt: 'select_account',
           image_aspect_ratio: 'square',
           image_size: 50
  
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']

  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']

  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']


end

OmniAuth.config.logger = Rails.logger
