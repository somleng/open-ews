class UpdateBroadcast < ApplicationWorkflow
  class InvalidStateTransitionError < StandardError; end

  attr_reader :broadcast, :desired_status, :target_area_records, :params

  def initialize(broadcast, desired_status: nil, target_area_records: [], **params)
    super()
    @broadcast = broadcast
    @desired_status = desired_status
    @target_area_records = target_area_records
    @params = params
  end

  def call
    broadcast.transaction do
      broadcast.update!(params)
      update_broadcast_target_areas if target_area_records.present?
      if desired_status.present?
        broadcast.transition_to!(desired_status)

        if params[:updated_by].present?
          broadcast.update!(started_by: params[:updated_by]) if broadcast.queued?
          broadcast.update!(stopped_by: params[:updated_by]) if broadcast.stopped?
        end
      end
    end

    if broadcast.queued?
      ExecuteWorkflowJob.perform_later(StartBroadcast.to_s, broadcast)
    else
      CreateEvent.call(type: "broadcast.updated", resource: broadcast)
    end

    broadcast
  rescue StateMachine::Machine::InvalidStateTransitionError => e
    raise InvalidStateTransitionError, e.message
  end

  private

  def update_broadcast_target_areas
    BroadcastTargetArea.where(broadcast_id: broadcast.id).delete_all

    records = Array(target_area_records).map do |record|
      record.merge(broadcast_id: broadcast.id)
    end

    BroadcastTargetArea.insert_all(records)
  end
end
