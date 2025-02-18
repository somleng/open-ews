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
      phone_call.complete!
      retry_call
    rescue ActiveRecord::StaleObjectError
      event.phone_call.reload
      retry
    end

    private

    def retry_call
      return unless phone_call.status.in?(RETRY_CALL_STATUSES + ALWAYS_RETRY_CALL_STATUSES)
      return if alert.blank?
      return if phone_call.status.in?(RETRY_CALL_STATUSES) && alert.phone_calls_count >= phone_call.account.max_phone_calls_for_alert
      return if alert.phone_calls_count >= MAX_RETRIES

      RetryPhoneCallJob.set(wait: 15.minutes).perform_later(phone_call)
    end

    def phone_call
      event.phone_call
    end

    def alert
      phone_call.alert
    end
  end
end

require_relative "hello_world"
require_relative "play_message"
