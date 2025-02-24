require "rails_helper"

RSpec.resource "Callout Participations" do
  header("Content-Type", "application/json")

  get "/api/callouts/:callout_id/callout_participations" do
    example "List all Callout Participations for a callout", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account: account)
      failed_alert = create_alert(account:, broadcast:, status: :queued)
      completed_alert = create_alert(account:, broadcast:, status: :completed)
      _other_alert = create_alert(account: account)

      set_authorization_header_for(account)
      do_request(callout_id: broadcast.id)

      expect(json_response.size).to eq(2)
      expect(json_response.pluck("id")).to contain_exactly(
        failed_alert.id,
        completed_alert.id
      )
      expect(json_response.dig(0, "answered")).to eq(true)
      expect(json_response.dig(1, "answered")).to eq(false)
    end
  end
end
