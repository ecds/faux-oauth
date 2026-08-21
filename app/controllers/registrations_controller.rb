class RegistrationsController < ActionController::Base
  include MailerDeliverable

  layout "application"
  rate_limit to: 5, within: 15.minutes, only: :create

  def new
    @user = User.new
    @origin = params[:origin]
  end

  def create
    @user = User.new(user_params)
    @origin = params[:origin]

    if @user.save
      @user.generate_confirmation_token!
      deliver_now_safely UserMailer.confirmation_instructions(@user, @origin)
      render :check_email
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation)
  end
end
