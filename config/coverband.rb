Coverband.configure do |config|
  config.logger = Rails.logger

  # default false. button at the top of the web interface which clears all data
  config.web_enable_clear = true

  # default false. Experimental support for routes usage tracking.
  config.track_routes = true
end
