# frozen_string_literal: true

require 'uri'

#
# Validates a value is a valid uri.
#
class UriValidator < ActiveModel::EachValidator

  #
  # Validate URL
  #
  # @param [ActiveRecord] record Model instance to be validated
  # @param [String] attribute to be validated
  # @param [Sting] value to be validated
  #
  # @return [Bolen] ture/valid, false/invalid
  #
  def validate_each(record, attribute, value)
    valid = begin
      URI.parse(value).kind_of?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end
    unless valid
      record.errors[attribute] << (options[:message] || "is an invalid URL. HINT: Ensure you are using https://")
    end
  end

end