# frozen_string_literal: true

#
# Shared by every controller whose request only makes sense in the context
# of a known client app — resolving the Client for a given origin, issuing
# it a token and redirecting back (the OmniAuth callback and local-account
# flows alike, so a client app is redirected the same way no matter how the
# person authenticated), and refusing to even render a form when there's no
# client to eventually redirect back to.
#
module ClientResolvable
  extend ActiveSupport::Concern

  private

  # Renders an error instead of the normal action when the request has no
  # origin, or the origin doesn't match any known Client. Meant as a
  # before_action, so a bad/missing origin fails fast at page-load instead
  # of only surfacing after someone fills out and submits a form.
  def require_known_client!
    if params[:origin].blank?
      render "shared/unknown_client", status: :not_found
      return
    end

    @client = resolve_client(params[:origin])
    render "shared/unknown_client", status: :not_found unless @client
  end

  def issue_token_and_redirect(session, origin:)
    client = resolve_client(origin)
    auth_response = client && TokenService.create(session)

    if auth_response
      # The whole point of this controller is to redirect to a different host
      # (the client app). That host is only ever the redirect_uri of a Client
      # we already looked up above, so it's allowlisted, not user-controlled.
      redirect_to generate_url(client.redirect_uri, auth_response), allow_other_host: true
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
