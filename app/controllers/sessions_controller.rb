class SessionsController < ActionController::Base
  include TokenIssuable

  layout "application"
  rate_limit to: 10, within: 3.minutes, only: :create

  def new
    @origin = params[:origin]
  end

  def create
    @origin = params[:origin]
    user = User.find_by(email: params[:email].to_s.downcase.strip)

    if user.nil? || !user.authenticate(params[:password])
      @error = "Invalid email or password."
      render :new, status: :unprocessable_entity
    elsif !user.confirmed?
      @error = "Please confirm your email before logging in."
      render :new, status: :unprocessable_entity
    else
      issue_token_and_redirect(user.to_session, origin: @origin)
    end
  end
end
