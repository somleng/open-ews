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
            channel: "voice",
            audio_url: "https://www.example.com/sample.mp3",
            beneficiary_filter: {
              gender: "M",
              "address.iso_region_code" => "KH-1"
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "channel" => "voice",
        "status" => "pending",
        "audio_url" => "https://www.example.com/sample.mp3",
        "beneficiary_filter" => {
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
            channel: "voice",
            audio_url: nil,
            beneficiary_filter: {}
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0, "source", "pointer")).to eq("/data/attributes/audio_url")
      expect(json_response.dig("errors", 1, "source", "pointer")).to eq("/data/attributes/beneficiary_filter")
    end
  end

  patch "/v1/broadcasts/:id" do
    example "Update a broadcasts" do
      account = create(:account)
      _male_beneficiary = create(:beneficiary, account:, gender: "M")
      female_beneficiary = create(:beneficiary, account:, gender: "F")
      broadcast = create(
        :broadcast,
        status: :pending,
        account:,
        audio_url: "https://www.example.com/old-sample.mp3",
        beneficiary_filter: {
          gender: "M"
        }
      )

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          id: broadcast.id,
          data: {
            id: broadcast.id,
            type: :broadcast,
            attributes: {
              status: "running",
              audio_url: "https://www.example.com/sample.mp3",
              beneficiary_filter: {
                gender: "F"
              }
            }
          }
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "status" => "queued",
        "audio_url" => "https://www.example.com/sample.mp3",
        "beneficiary_filter" => {
          "gender" => "F"
        }
      )
      expect(broadcast.reload.status).to eq("running")
      expect(broadcast.beneficiaries).to match_array([ female_beneficiary ])
      expect(broadcast.delivery_attempts.count).to eq(1)
      expect(broadcast.delivery_attempts.first.beneficiary).to eq(female_beneficiary)
    end

    example "Failed to update a broadcast", document: false do
      account = create(:account)
      broadcast = create(
        :broadcast,
        account:,
        status: :running
      )

      set_authorization_header_for(account)
      do_request(
        id: broadcast.id,
        data: {
          id: broadcast.id,
          type: :broadcast,
          attributes: {
            status: "pending",
            audio_url: "https://www.example.com/sample.mp3"
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0, "source", "pointer")).to eq("/data/attributes/status")
    end
  end
end
