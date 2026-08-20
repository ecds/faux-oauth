class HealthCheckController < ApplicationController
  rescue_from(Exception) { render head: 503 }

  def show
    render head: 200
  end
end
