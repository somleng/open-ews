class HandleRecordingStatusCallback < ApplicationWorkflow
  attr_reader :recording_params

  def initialize(recording_params)
    @recording_params = recording_params
  end

  def call
    Recording.transaction do
      recording = create_recording
      recording.audio_file.attach(
        io: URI.parse("#{recording_params.fetch(:recording_url)}.mp3").open,
        filename: "#{recording_params.fetch(:recording_sid)}.mp3"
      )
      recording
    end
  end

  private

  def create_recording
    delivery_attempt = DeliveryAttempt.find_by!(remote_call_id: recording_params.fetch(:call_sid))

    Recording.create!(
      delivery_attempt:,
      beneficiary: delivery_attempt.beneficiary,
      account: delivery_attempt.account,
      external_recording_id: recording_params.fetch(:recording_sid),
      external_recording_url: recording_params.fetch(:recording_url),
      duration: recording_params.fetch(:recording_duration)
    )
  end
end
