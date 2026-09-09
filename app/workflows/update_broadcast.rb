class UpdateBroadcast < ApplicationWorkflow
  class InvalidStateTransitionError < StandardError; end

  attr_reader :broadcast, :desired_status, :params

  def initialize(broadcast, desired_status: nil, **params)
    super()
    @broadcast = broadcast
    @desired_status = desired_status
    @params = params
  end

  def call
    broadcast.transaction do
      broadcast.update!(params)
      update_broadcast_target_areas if params.key?(:target_area_data)
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
    BroadcastTargetArea.insert_all(BuildBroadcastTargetAreaRecords.call(broadcast))
  end
end
