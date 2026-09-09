class CreateBroadcast < ApplicationWorkflow
  attr_reader :desired_status, :params

  def initialize(desired_status: nil, **params)
    super()
    @desired_status = desired_status
    @params = params
  end

  def call
    Broadcast.transaction do
      broadcast = Broadcast.create!(params)
      broadcast.transition_to!(desired_status) if desired_status.present?
      BroadcastTargetArea.insert_all(
        BuildBroadcastTargetAreaRecords.call(broadcast),
        unique_by: [ :broadcast_id, :administrative_level, :geocode ]
      )
      ExecuteWorkflowJob.perform_later(StartBroadcast.to_s, broadcast) if broadcast.queued?
      CreateEvent.call(type: "broadcast.created", resource: broadcast)
      broadcast
    end
  end
end
