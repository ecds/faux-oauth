class ConfirmationsController < ActionController::Base
  include MailerDeliverable

  layout "application"
  rate_limit to: 5, within: 15.minutes, only: :create

  def show
    user = User.find_by(confirmation_token: params[:token])

    if user.nil?
      render plain: "Invalid or expired confirmation link.", status: :not_found
      return
    end

    user.confirm!
    @origin = params[:origin]
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
