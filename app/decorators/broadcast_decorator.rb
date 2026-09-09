class BroadcastDecorator < ApplicationDecorator
  ORDERED_STATUSES = %i[succeeded failed pending].freeze

  delegate :notifications, to: :object, private: true

  def notification_stats
    @notification_stats ||= begin
      stats = generate_stats
      ORDERED_STATUSES.each_with_object({}) { |s, result| result[s] = stats.fetch(s, 0) }
    end
  end

  def notification_stats_percentage
    notification_stats.transform_values do |count|
      next 0 if total_notifications_count.zero?

      (count.to_f / total_notifications_count) * 100
    end
  end

  def total_notifications_count
    @total_notifications_count ||= preview? ? approximate_notifications_count : notifications.count
  end

  def approximate_beneficiaries
    @approximate_beneficiaries ||= ApplicationController.helpers.pluralize_model(
      approximate_notifications_count,
      Beneficiary.model_name,
      formatter: ->(count) { ActiveSupport::NumberHelper.number_to_human(count) }
    )
  end

  def state_machine
    @state_machine ||= BroadcastStateMachine.new(object.status)
  end

  private

  def generate_stats
    preview? ? preview_stats : notifications.group(:status).count.symbolize_keys
  end

  def preview_stats
    { pending: approximate_notifications_count }
  end

  def preview?
    channel_capabilities.any?(&:deliverable?) && notifications.none?
  end

  def broadcast_preview
    @broadcast_preview ||= BroadcastPreview.new(object)
  end

  def approximate_notifications_count
    @approximate_notifications_count ||= broadcast_preview.beneficiaries.count
  end
end
