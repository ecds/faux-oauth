# frozen_string_literal: true

#
# A locally-authenticated account, for users who don't have Google/GitHub/etc.
# Produces the same session shape as the OmniAuth providers so client apps
# never see a difference based on how someone signed in.
#
class User < ApplicationRecord
  has_secure_password

  before_validation { self.email = email.to_s.downcase.strip }

  validates :email, presence: true, uniqueness: true,
                     format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 12 }, allow_nil: true

  RESET_PASSWORD_TOKEN_VALID_FOR = 2.hours

  def confirmed?
    confirmed_at.present?
  end

  def generate_confirmation_token!
    update!(confirmation_token: SecureRandom.urlsafe_base64(32), confirmation_sent_at: Time.current)
  end

  def confirm!
    update!(confirmed_at: Time.current, confirmation_token: nil)
  end

  def generate_reset_password_token!
    update!(reset_password_token: SecureRandom.urlsafe_base64(32), reset_password_sent_at: Time.current)
  end

  def reset_password_token_valid?
    reset_password_sent_at.present? && reset_password_sent_at > RESET_PASSWORD_TOKEN_VALID_FOR.ago
  end

  def clear_reset_password_token!
    update!(reset_password_token: nil, reset_password_sent_at: nil)
  end

  #
  # The session hash handed to TokenService, matching the shape TokensController
  # builds from an OmniAuth hash so client apps get an identical token either way.
  #
  def to_session
    {
      provider: "local",
      who: email,
      name: name,
      uid: Digest::SHA1.hexdigest(id.to_s)
    }
  end
end
