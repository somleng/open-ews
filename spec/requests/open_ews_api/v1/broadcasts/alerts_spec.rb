require "rails_helper"

RSpec.resource "Broadcasts"  do
  get "/v1/broadcasts/:broadcast_id/alerts" do
    with_options scope: :filter do
      parameter(:status, "The status of the alert. Must be one of `completed`, `queued`.", required: false, method: :_disabled)
    end
    example "List all alerts for a broadcast" do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      alerts = create_list(:alert, 3, broadcast: broadcast)
      _other_alert = create(:alert)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("alert")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        *alerts.map(&:id).map(&:to_s)
      )
    end


    example "List all alerts for a broadcast with filters", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      completed_alerts = create_list(:alert, 2, status: :completed, broadcast: broadcast)
      _queued_alerts = create(:alert, status: :queued, broadcast: broadcast)
      _other_alert = create(:alert)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id, filter: { status: { eq: "completed" } })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("alert")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        *completed_alerts.map(&:id).map(&:to_s)
      )
    end

    example "List all alerts for a broadcast include their associations", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      create_list(:alert, 2, broadcast: broadcast)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id, include: "beneficiary,broadcast")

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("alert")
      expect(json_response.fetch("included").pluck("type").uniq).to contain_exactly(
        "beneficiary", "broadcast"
      )
    end
  end
end
