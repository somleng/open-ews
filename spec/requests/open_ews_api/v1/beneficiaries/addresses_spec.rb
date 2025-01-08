require "rails_helper"

RSpec.resource "Beneficiary's Addresses"  do
  get "/v1/beneficiaries/:beneficiary_id/addresses" do
    example "List all a beneficiary's addresses" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      address1 = create(:beneficiary_address, beneficiary:)
      address2 = create(:beneficiary_address, beneficiary:)
      other_beneficiary = create(:beneficiary)
      _other_address = create(:beneficiary_address, beneficiary: other_beneficiary)

      set_authorization_header_for(account)
      do_request(beneficiary_id: beneficiary.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("address")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        address1.id.to_s,
        address2.id.to_s
      )
    end
  end

  post "/v1/beneficiaries/:beneficiary_id/addresses" do
    example "Create an address for a beneficiary" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)

      set_authorization_header_for(account)
      do_request(
        beneficiary_id: beneficiary.id,
        data: {
          type: :address,
          attributes: {
            iso_country_code: "KH",
            iso_region_code: "KH-1",
            administrative_division_level_2_code: "01"
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("address")
      expect(jsonapi_response_attributes).to include(
        "iso_country_code" => "KH",
        "iso_region_code" => "KH-1",
        "administrative_division_level_2_code" => "01"
      )
    end
  end

  get "/v1/beneficiaries/:beneficiary_id/addresses/:id" do
    example "Get an address for a beneficiary" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      address = create(:beneficiary_address, beneficiary:)

      set_authorization_header_for(account)
      do_request(
        beneficiary_id: beneficiary.id,
        id: address.id
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("address")
      expect(json_response.dig("data", "id")).to eq(address.id.to_s)
    end
  end

  delete "/v1/beneficiaries/:beneficiary_id/addresses/:id" do
    example "Delete an address for a beneficiary" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      address = create(:beneficiary_address, beneficiary:)

      set_authorization_header_for(account)
      do_request(
        beneficiary_id: beneficiary.id,
        id: address.id
      )

      expect(response_status).to eq(204)
    end
  end
end
