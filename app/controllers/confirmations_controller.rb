class ConfirmationsController < ActionController::Base
  def show
    user = User.find_by(confirmation_token: params[:token])

    if user.nil?
      render plain: "Invalid or expired confirmation link.", status: :not_found
      return
    end

    user.confirm!
    @origin = params[:origin]
  end
end
