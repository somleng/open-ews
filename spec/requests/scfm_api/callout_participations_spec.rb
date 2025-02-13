require "rails_helper"

RSpec.resource "Callout Participations" do
  header("Content-Type", "application/json")

  get "/api/callouts/:callout_id/callout_participations" do
    example "List all Callout Participations for a callout", document: false do
      callout_participation = create_callout_participation(account: account)
      _other_callout_participation = create_callout_participation(account: account)

      set_authorization_header_for(account)
      do_request(callout_id: callout_participation.broadcast_id)

      assert_filtered!(callout_participation)
    end
  end

  def assert_filtered!(callout_participation)
    expect(response_status).to eq(200)
    parsed_body = JSON.parse(response_body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(callout_participation.id)
  end

  let(:account) { create(:account) }
end
