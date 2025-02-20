require "rails_helper"

RSpec.resource "Phone Calls" do
  header("Content-Type", "application/json")

  get "/api/phone_calls" do
    example "List all Phone Calls" do
      delivery_attempt = create_delivery_attempt(
        account:,
        metadata: {
          "foo" => "bar"
        }
      )

      create_delivery_attempt(account:)
      create(:delivery_attempt)

      set_authorization_header_for(account)
      do_request(
        q: {
          "metadata" => { "foo" => "bar" }
        }
      )

      assert_filtered!(delivery_attempt)
    end
  end

  get "/api/callouts/:callout_id/phone_calls" do
    example "List phone calls for a callout", document: false do
      delivery_attempt = create_delivery_attempt(account:)
      _other_delivery_attempt = create_delivery_attempt(account:)

      set_authorization_header_for(account)
      do_request(callout_id: delivery_attempt.broadcast.id)

      assert_filtered!(delivery_attempt)
    end
  end

  get "/api/phone_calls/:id" do
    example "Retrieve a Phone Call" do
      delivery_attempt = create_delivery_attempt(account:)

      set_authorization_header_for(account)
      do_request(id: delivery_attempt.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.delivery_attempts.find(parsed_response.fetch("id"))
      ).to eq(delivery_attempt)
    end
  end

  def assert_filtered!(delivery_attempt)
    expect(response_status).to eq(200)
    parsed_body = JSON.parse(response_body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(delivery_attempt.id)
  end

  let(:account) { create(:account) }
end
