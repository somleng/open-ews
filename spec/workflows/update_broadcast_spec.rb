require "rails_helper"

RSpec.describe UpdateBroadcast do
  it "updates a broadcast" do
    broadcast = create(:broadcast, :pending)
    create(:broadcast_target_area, broadcast:, administrative_level: 1, geocode: "KH-2")

    UpdateBroadcast.call(
      broadcast,
      target_area_records: [
        { administrative_level: 1, geocode: "KH-1" },
        { administrative_level: 2, geocode: "0201" }
      ]
    )

    expect(broadcast.reload).to have_attributes(
      target_areas: contain_exactly(
        have_attributes(
          administrative_level: 1,
          geocode: "KH-1"
        ),
        have_attributes(
          administrative_level: 2,
          geocode: "0201"
        )
      )
    )
  end

  it "updates the broadcast state" do
    broadcast = create(:broadcast, :running)

    UpdateBroadcast.call(broadcast, desired_status: :completed)

    expect(broadcast).to have_attributes(
      status: "completed",
      account: have_attributes(
        events: contain_exactly(
          have_attributes(
            type: "broadcast.updated",
          )
        )
      )
    )
  end

  it "sets started by" do
    broadcast = create(:broadcast, :pending)
    user = create(:user, account: broadcast.account)

    UpdateBroadcast.call(broadcast, desired_status: :queued, updated_by: user)

    expect(broadcast).to have_attributes(status: "queued", started_by: user, updated_by: user)
  end

  it "sets stopped by" do
    broadcast = create(:broadcast, :running)
    user = create(:user, account: broadcast.account)

    UpdateBroadcast.call(broadcast, desired_status: :stopped, updated_by: user)

    expect(broadcast).to have_attributes(status: "stopped", stopped_by: user, updated_by: user)
  end

  it "raises an error when the desired status is invalid" do
    broadcast = create(:broadcast, :pending)

    expect { UpdateBroadcast.call(broadcast, desired_status: :stopped) }.to raise_error(UpdateBroadcast::InvalidStateTransitionError)
  end
end
