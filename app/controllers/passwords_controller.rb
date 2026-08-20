class PasswordsController < ActionController::Base
  layout "application"
  rate_limit to: 5, within: 15.minutes, only: :create

  def new
    @origin = params[:origin]
  end

  def create
    @origin = params[:origin]
    user = User.find_by(email: params[:email].to_s.downcase.strip)

    if user
      user.generate_reset_password_token!
      UserMailer.reset_password_instructions(user, @origin).deliver_later
    end

    # Always show the same message, whether or not the email matched, so this
    # can't be used to check which emails have accounts.
    render :check_email
  end

  def edit
    @token = params[:token]
    @origin = params[:origin]
    render plain: "Invalid or expired reset link.", status: :not_found unless valid_token_user
  end

  def update
    @origin = params[:origin]
    user = valid_token_user

    if user.nil?
      render plain: "Invalid or expired reset link.", status: :not_found
      return
    end

    if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      user.clear_reset_password_token!
      render :updated
    else
      @token = params[:token]
      @origin = params[:origin]
      @errors = user.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def valid_token_user
    user = User.find_by(reset_password_token: params[:token])
    user if user&.reset_password_token_valid?
  end
end
