require "rails_helper"

RSpec.describe ScheduledJob do
  it "queues delivery attempts per account" do
    account = create(:account)

    created_delivery_attempt_from_running_broadcast = create_delivery_attempt(
      account:,
      status: :created,
      broadcast_status: :running
    )
    created_delivery_attempt_from_stopped_broadcast = create_delivery_attempt(
      account:,
      status: :created,
      broadcast_status: :stopped
    )
    queued_delivery_attempt = create_delivery_attempt(
      account:,
      status: :queued,
      broadcast_status: :running
    )

    ScheduledJob.perform_now

    expect(created_delivery_attempt_from_running_broadcast.reload.status).to eq("queued")
    expect(created_delivery_attempt_from_stopped_broadcast.reload.status).to eq("created")
    expect(queued_delivery_attempt.reload.status).to eq("queued")

    expect(QueueRemoteCallJob).to have_been_enqueued.exactly(:once)
    expect(QueueRemoteCallJob).to have_been_enqueued.with(created_delivery_attempt_from_running_broadcast)
  end

  it "fetches in progress call statuses" do
    account = create(:account)

    in_progress_delivery_attempt = create_delivery_attempt(
      account:,
      status: :in_progress,
      remotely_queued_at: 10.minutes.ago
    )
    _in_progress_recent_delivery_attempt = create_delivery_attempt(
      account:,
      status: :in_progress,
      remotely_queued_at: Time.current
    )
    _in_progress_queued_for_fetch_delivery_attempt = create_delivery_attempt(
      account:,
      status: :in_progress,
      remotely_queued_at: 10.minutes.ago,
      remote_status_fetch_queued_at: Time.current
    )
    in_progress_queued_for_fetch_expired_delivery_attempt = create_delivery_attempt(
      account:,
      status: :in_progress,
      remotely_queued_at: 10.minutes.ago,
      remote_status_fetch_queued_at: 20.minutes.ago
    )

    ScheduledJob.perform_now

    expect(FetchRemoteCallJob).to have_been_enqueued.exactly(:twice)
    expect(FetchRemoteCallJob).to have_been_enqueued.with(in_progress_delivery_attempt)
    expect(FetchRemoteCallJob).to have_been_enqueued.with(in_progress_queued_for_fetch_expired_delivery_attempt)
    expect(in_progress_delivery_attempt.reload.remote_status_fetch_queued_at).to be_present
  end

  def create_delivery_attempt(account:, broadcast_status: :running, **attributes)
    broadcast = create(:broadcast, account:, status: broadcast_status)
    alert = create_alert(account:, broadcast:)

    create(:delivery_attempt, account:, broadcast:, alert:, **attributes)
  end
end
