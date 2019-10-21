# frozen_string_literal: true

require 'uri'

#
# <Description>
#
class Client < ApplicationRecord
  before_validation :set_host
  validates :redirect_uri, presence: true
  validates :host, presence: true
  validates :redirect_uri, presence: true

  private

  #
  # Extract the root host from the Client's redirect_uri
  #
  # @return [String] Root host name for Client
  #
  def set_host
    return nil if redirect_uri.nil?
    self.host = URI.parse(redirect_uri).host
  end
end
