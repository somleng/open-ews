require "rails_helper"

RSpec.resource "Beneficiaries"  do
  get "/v1/beneficiaries" do
    example "List all active beneficiaries" do
      account = create(:account)
      account_beneficiary = create(:beneficiary, account:)
      _account_disabled_beneficiary = create(:beneficiary, :disabled, account:)
      _other_account_beneficiary = create(:beneficiary)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        account_beneficiary.id.to_s
      )
    end

    example "List all disabled beneficiaries", document: false do
      account = create(:account)
      _active_beneficiary = create(:beneficiary, account:)
      disabled_beneficiary = create(:beneficiary, :disabled, account:, status: "disabled")

      set_authorization_header_for(account)
      do_request(filter: { status: "disabled" })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        disabled_beneficiary.id.to_s
      )
    end
  end

  post "/v1/beneficiaries" do
    example "Create a beneficiary" do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :beneficiary,
          attributes: {
            msisdn: "+85510999999",
            language_code: "km",
            gender: "M",
            date_of_birth: "1990-01-01",
            metadata: { "foo" => "bar" },
            iso_country_code: "KH",
            address: {
              iso_region_code: "KH-1",
              administrative_division_level_2_code: "01"
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(jsonapi_response_attributes).to include(
        "msisdn" => "+85510999999",
        "language_code" => "km",
        "gender" => "M",
        "date_of_birth" => "1990-01-01",
        "metadata" => { "foo" => "bar" },
        "iso_country_code" => "KH",
      )

      expect(json_response.dig("included", 0).to_json).to match_api_response_schema("address")
      expect(json_response.dig("included", 0, "attributes")).to include(
        "iso_region_code" => "KH-1",
        "administrative_division_level_2_code" => "01"
      )
    end

    example "Fail to create a beneficiary", document: false do
      account = create(:account)
      create(:beneficiary, account:, msisdn: "+85510999999")

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :beneficiary,
          attributes: {
            msisdn: "+85510999999",
            iso_country_code: "kh"
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0)).to include(
        "title" => "must be unique",
        "source" => { "pointer" => "/data/attributes/msisdn" }
      )
    end
  end

  get "/v1/beneficiaries/:id" do
    example "Get a beneficiary" do
      beneficiary = create(:beneficiary)

      set_authorization_header_for(beneficiary.account)
      do_request(id: beneficiary.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(json_response.dig("data", "id")).to eq(beneficiary.id.to_s)
    end
  end

  patch "/v1/beneficiaries/:id" do
    example "Update a beneficiary" do
      beneficiary = create(
        :beneficiary,
        msisdn: "+85510999001",
        gender: nil,
        language_code: nil,
        date_of_birth: nil,
        metadata: {}
      )

      set_authorization_header_for(beneficiary.account)
      do_request(
        id: beneficiary.id,
        data: {
          id: beneficiary.id,
          type: :beneficiary,
          attributes: {
            msisdn: "+85510999002",
            gender: "F",
            status: "disabled",
            language_code: "en",
            date_of_birth: "1990-01-01",
            metadata: {
              foo: "bar"
            }
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(jsonapi_response_attributes).to include(
        "msisdn" => "+85510999002",
        "language_code" => "en",
        "gender" => "F",
        "date_of_birth" => "1990-01-01",
        "metadata" => { "foo" => "bar" }
      )
    end
  end
end
