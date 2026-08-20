# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def confirmation_instructions(user, origin)
    @user = user
    @confirm_url = confirm_url(token: user.confirmation_token, origin: origin)

    mail(to: user.email, subject: "Confirm your account")
  end

  def reset_password_instructions(user, origin)
    @user = user
    @edit_password_url = edit_password_url(token: user.reset_password_token, origin: origin)

    mail(to: user.email, subject: "Reset your password")
  end
end
