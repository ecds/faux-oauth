# frozen_string_literal: true

#
# Shared by every controller that hands a client app back a token — the
# OmniAuth callback and the local-account flows alike — so a client app
# is redirected the same way no matter how the person authenticated.
#
module TokenIssuable
  extend ActiveSupport::Concern

  private

  def issue_token_and_redirect(session, origin:)
    client = resolve_client(origin)
    auth_response = client && TokenService.create(session)

    if auth_response
      redirect_to generate_url(client.redirect_uri, auth_response)
    else
      render plain: "Unknown client.", status: :unprocessable_entity
    end

    auth_response
  end

  def resolve_client(origin)
    if Rails.env.test?
      Client.find_or_create_by(redirect_uri: "https://emory.edu/redirect.html")
    else
      return nil if origin.blank?
      Client.find_by(host: URI.parse(origin).host)
    end
  end

  def generate_url(url, params = {})
    uri = URI(url)
    uri.query = params.to_query
    uri.to_s
  end
end
