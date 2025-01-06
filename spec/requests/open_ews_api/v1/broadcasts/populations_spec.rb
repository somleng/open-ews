require "rails_helper"

RSpec.resource "Broadcast's Populations"  do
  get "/v1/broadcasts/:broadcast_id/populations" do
    example "List all broadcast's populations" do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      broadcast_populations = create_list(:broadcast_population, 2, callout: broadcast)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("broadcast_population")
      expect(json_response.fetch("data").pluck("id")).to match_array(broadcast_populations.pluck(:id).map(&:to_s))
    end
  end

  get "/v1/broadcasts/:broadcast_id/populations/:id" do
    example "Get a broadcast's population" do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      broadcast_population = create(:broadcast_population, callout: broadcast)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id, id: broadcast_population.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast_population")
      expect(json_response.dig("data", "id")).to eq(broadcast_population.id.to_s)
    end
  end

  post "/v1/broadcasts/:broadcast_id/populations" do
    example "Create a broadcast's population" do
      account = create(:account)
      broadcast = create(:broadcast, account:)

      set_authorization_header_for(account)
      do_request(
        broadcast_id: broadcast.id,
        data: {
          type: :broadcast_population,
          attributes: {
            parameters: {
              gender: "M",
              address: {
                "administrative_division_level_3_code.any": ["020101", "020102"]
              }
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast_population")
      expect(jsonapi_response_attributes).to include(
        "parameters" => {
          "gender" => "M",
          "address" => {
            "administrative_division_level_3_code.any" => ["020101", "020102"]
          }
        },
      )
    end
  end
end
