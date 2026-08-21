class ConfirmationsController < ActionController::Base
  include MailerDeliverable
  include ClientResolvable

  layout "application"
  rate_limit to: 5, within: 15.minutes, only: :create
  # :show (the emailed confirmation link) intentionally isn't gated on this —
  # confirming the address is worth completing on its own even if the origin
  # is missing or stale; only the resend form needs a live client to send to.
  before_action :require_known_client!

  def show
    user = User.find_by(confirmation_token: params[:token])

    if user.nil?
      render plain: "Invalid or expired confirmation link.", status: :not_found
      return
    end

    user.confirm!
    @origin = params[:origin]
    redirect_to generate_url(@client.redirect_uri), allow_other_host: true
  end

  def new
    @origin = params[:origin]
  end

  def create
    @origin = params[:origin]
    user = User.find_by(email: params[:email].to_s.downcase.strip)

    if user && !user.confirmed?
      user.generate_confirmation_token!
      deliver_now_safely UserMailer.confirmation_instructions(user, @origin)
    end

    # Always show the same message, whether or not the email matched an
    # unconfirmed account, so this can't be used to check which emails have
    # accounts (same reasoning as PasswordsController#create).
    render :check_email
  end
end
