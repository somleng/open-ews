module CallFlowLogic
  class Base
    attr_accessor :options

    RETRY_CALL_STATUSES = %w[not_answered busy failed].freeze
    ALWAYS_RETRY_CALL_STATUSES = %w[canceled expired errored].freeze
    MAX_RETRIES = 10

    def self.registered
      @registered ||= descendants.reject(&:abstract_class?).map(&:to_s)
    end

    def self.abstract_class?
      false
    end

    def initialize(options = {})
      self.options = options
    end

    def event
      options.fetch(:event)
    end

    def current_url
      options.fetch(:current_url)
    end

    def run!
      delivery_attempt.complete!
      retry_call
    rescue ActiveRecord::StaleObjectError
      event.delivery_attempt.reload
      retry
    end

    private

    def retry_call
      return unless delivery_attempt.status.in?(RETRY_CALL_STATUSES + ALWAYS_RETRY_CALL_STATUSES)
      return if alert.blank?
      return if delivery_attempt.status.in?(RETRY_CALL_STATUSES) && alert.delivery_attempts_count >= delivery_attempt.account.max_delivery_attempts_for_alert
      return if alert.delivery_attempts_count >= MAX_RETRIES

      RetryDeliveryAttemptJob.set(wait: 15.minutes).perform_later(delivery_attempt)
    end

    def delivery_attempt
      event.delivery_attempt
    end

    def alert
      delivery_attempt.alert
    end
  end
end

require_relative "hello_world"
require_relative "play_message"
