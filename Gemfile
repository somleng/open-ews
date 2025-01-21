source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 8.0.1"

# The modern asset pipeline for Rails
gem "propshaft"

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
# gem "solid_cache"
# gem "solid_queue"
# gem "solid_cable"

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
# gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

gem "aasm", github: "aasm/aasm"
gem "after_commit_everywhere"
gem "api-pagination", github: "davidcelis/api-pagination"
gem "appsignal"
gem "aws-sdk-cloudwatch"
gem "aws-sdk-rails"
gem "aws-sdk-s3", require: false
gem "aws-sdk-sqs"
gem "aws-actionmailer-ses"
gem "bitmask_attributes", github: "numerex/bitmask_attributes"
gem "bootsnap", require: false
gem "cocoon"
gem "cssbundling-rails"
gem "countries"
gem "cursor_paginator"
gem "devise"
gem "devise-async"
gem "devise_invitable"
gem "doorkeeper"
gem "dry-validation"
gem "enumerize"
gem "faraday"
gem "file_validators"
gem "haml-rails"
gem "jsbundling-rails"
gem "jsonapi-serializer"
gem "kaminari"
gem "lograge"
gem "okcomputer"
gem "pg"
gem "pghero"
gem "pg_query"
gem "phony"
gem "phony_rails"
gem "puma"
gem "pumi"
gem "record_tag_helper", github: "rails/record_tag_helper"
gem "responders"
gem "sentry-rails"
gem "shoryuken"
gem "show_for"
gem "simple_form"
gem "skylight"
gem "stimulus-rails"
gem "strip_attributes"
gem "turbo-rails"
gem "twilio-ruby"
gem "tzinfo-data"

group :development, :test do
  gem "brakeman", require: false
  gem "i18n-tasks"
  gem "pry"
  # Support Rack 3.1 https://github.com/zipmark/rspec_api_documentation/issues/548
  gem "rspec_api_documentation", github: "samnang/rspec_api_documentation", branch: "fix-supporting-rack-3"
  gem "rspec-rails"
end

group :development do
  gem "listen"
  gem "rubocop-performance"
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
end

group :test do
  gem "capybara"
  gem "email_spec"
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "simplecov-lcov", require: false
  gem "webmock"
end
