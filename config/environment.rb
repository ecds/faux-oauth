# Load the Rails application.
require_relative "application"

Rails.application.configure do
  config.active_support.to_time_preserves_timezone = :zone
end
Rails.application.initialize!
