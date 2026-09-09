class CreateBroadcast < ApplicationWorkflow
  attr_reader :desired_status, :target_area_records, :params

  def initialize(desired_status: nil, target_area_records: [], **params)
    super()
    @desired_status = desired_status
    @target_area_records = target_area_records
    @params = params
  end

  def call
    Broadcast.transaction do
      broadcast = Broadcast.create!(params)
      broadcast.transition_to!(desired_status) if desired_status.present?
      BroadcastTargetArea.insert_all(broadcast_target_area_records(broadcast))
      ExecuteWorkflowJob.perform_later(StartBroadcast.to_s, broadcast) if broadcast.queued?
      CreateEvent.call(type: "broadcast.created", resource: broadcast)
      broadcast
    end
  end

  private

  def broadcast_target_area_records(broadcast)
    Array(target_area_records).map do |record|
      record.merge(broadcast_id: broadcast.id)
    end
  end
end
