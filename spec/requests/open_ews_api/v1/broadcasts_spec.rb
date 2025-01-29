require "rails_helper"

RSpec.resource "Broadcasts"  do
  get "/v1/broadcasts" do
    example "List all broadcasts" do
      account = create(:account)
      account_broadcast = create(:broadcast, account:)
      _other_account_broadcast = create(:broadcast)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("broadcast")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        account_broadcast.id.to_s
      )
    end
  end

  get "/v1/broadcasts/:id" do
    example "Get a broadcasts" do
      account = create(:account)
      broadcast = create(:broadcast, account:)

      set_authorization_header_for(account)
      do_request(id: broadcast.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "id")).to eq(broadcast.id.to_s)
    end
  end

  post "/v1/broadcasts" do
    example "Create a broadcasts" do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :broadcast,
          attributes: {
            audio_url: "https://www.example.com/sample.mp3",
            beneficiary_parameters: {
              gender: "M",
              "address.iso_region_code" => "KH-1"
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "status" => "pending",
        "audio_url" => "https://www.example.com/sample.mp3",
        "beneficiary_parameters" => {
          "gender" => "M",
          "address.iso_region_code" => "KH-1"
        }
      )
    end

    example "Failed to create a broadcast", document: false do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :broadcast,
          attributes: {
            audio_url: nil,
            beneficiary_parameters: {}
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0, "source", "pointer")).to eq("/data/attributes/audio_url")
      expect(json_response.dig("errors", 1, "source", "pointer")).to eq("/data/attributes/beneficiary_parameters")
    end
  end
end
