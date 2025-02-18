require "rails_helper"

RSpec.resource "Callout Participations" do
  header("Content-Type", "application/json")

  get "/api/callouts/:callout_id/callout_participations" do
    example "List all Callout Participations for a callout", document: false do
      alert = create_alert(account: account)
      _other_alert = create_alert(account: account)

      set_authorization_header_for(account)
      do_request(callout_id: alert.broadcast_id)

      assert_filtered!(alert)
    end
  end

  def assert_filtered!(alert)
    expect(response_status).to eq(200)
    parsed_body = JSON.parse(response_body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(alert.id)
  end

  let(:account) { create(:account) }
end
