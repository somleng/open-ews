require "rails_helper"

RSpec.resource "Beneficiary addresses"  do
  get "/v1/beneficiaries/:beneficiary_id/addresses" do
    example "List all addresses for a beneficiary" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      address1 = create(:beneficiary_address, :full, beneficiary:)
      address2 = create(:beneficiary_address, :full, beneficiary:, administrative_division_level_4_code: "01020102", administrative_division_level_4_name: "Phnum")
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
    with_options scope: %i[data] do
      parameter(
        :type, "Must be `address`",
        required: true
      )
    end

    with_options scope: %i[data attributes] do
      parameter(
        :iso_region_code, "The [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) region code of the address",
        required: true
      )
      parameter(
        :administrative_division_level_2_code, "The second-level administrative subdivision code of the address (e.g. district code)",
        required: false
      )
      parameter(
        :administrative_division_level_2_name, "The second-level administrative subdivision name of the address (e.g. district name)",
        required: false
      )
      parameter(
        :administrative_division_level_3_code, "The third-level administrative subdivision code of the address (e.g. commune code)",
        required: false
      )
      parameter(
        :administrative_division_level_3_name, "The third-level administrative subdivision name of the address (e.g. commune name)",
        required: false
      )
      parameter(
        :administrative_division_level_4_code, "The forth-level administrative subdivision code of the address (e.g. village code)",
        required: false
      )
      parameter(
        :administrative_division_level_4_name, "The forth-level administrative subdivision name of the address (e.g. village name)",
        required: false
      )
    end

    example "Create an address for a beneficiary" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)

      set_authorization_header_for(account)
      do_request(
        beneficiary_id: beneficiary.id,
        data: {
          type: :address,
          attributes: {
            iso_region_code: "KH-1",
            administrative_division_level_2_code: "0102",
            administrative_division_level_2_name: "Mongkol Borei",
            administrative_division_level_3_code: "010201",
            administrative_division_level_3_name: "Banteay Neang",
            administrative_division_level_4_code: "01020101",
            administrative_division_level_4_name: "Ou Thum"
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("address")
      expect(jsonapi_response_attributes).to include(
        "iso_region_code" => "KH-1",
        "administrative_division_level_2_code" => "0102",
        "administrative_division_level_2_name" => "Mongkol Borei",
        "administrative_division_level_3_code" => "010201",
        "administrative_division_level_3_name" => "Banteay Neang",
        "administrative_division_level_4_code" => "01020101",
        "administrative_division_level_4_name" => "Ou Thum"
      )
    end
  end

  get "/v1/beneficiaries/:beneficiary_id/addresses/:id" do
    example "Fetch an address for a beneficiary" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      address = create(:beneficiary_address, :full, beneficiary:)

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
