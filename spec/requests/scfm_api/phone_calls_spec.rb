require "rails_helper"

RSpec.resource "Phone Calls" do
  header("Content-Type", "application/json")

  get "/api/phone_calls" do
    example "List all Phone Calls" do
      phone_call = create_phone_call(
        account:,
        metadata: {
          "foo" => "bar"
        }
      )

      create_phone_call(account:)
      create(:phone_call)

      set_authorization_header_for(account)
      do_request(
        q: {
          "metadata" => { "foo" => "bar" }
        }
      )

      assert_filtered!(phone_call)
    end
  end

  get "/api/callouts/:callout_id/phone_calls" do
    example "List phone calls for a callout", document: false do
      phone_call = create_phone_call(account:)
      _other_phone_call = create_phone_call(account:)

      set_authorization_header_for(account)
      do_request(callout_id: phone_call.callout.id)

      assert_filtered!(phone_call)
    end
  end

  get "/api/phone_calls/:id" do
    example "Retrieve a Phone Call" do
      phone_call = create_phone_call(account:)

      set_authorization_header_for(account)
      do_request(id: phone_call.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.phone_calls.find(parsed_response.fetch("id"))
      ).to eq(phone_call)
    end
  end

  def assert_filtered!(phone_call)
    expect(response_status).to eq(200)
    parsed_body = JSON.parse(response_body)
    expect(parsed_body.size).to eq(1)
    expect(parsed_body.first.fetch("id")).to eq(phone_call.id)
  end

  let(:account) { create(:account) }
end
