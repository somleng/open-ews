require "rails_helper"

RSpec.resource "Beneficiaries"  do
  get "/v1/beneficiaries" do
    with_options scope: :filter do
      parameter(
        :status, "Must be one of #{Contact.status.values.map { |t| "`#{t}`" }.join(", ")}.",
        required: false
      )
    end

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
    with_options scope: %i[data attributes] do
      parameter(
        :msisdn, "Phone number in E.164 format or shortcode.",
        required: true
      )
      parameter(
        :language_code, "Language code in ISO 639-1 format.",
        required: false
      )
      parameter(
        :gender, "Must be one of `M` or `F`.",
        required: false
      )
      parameter(
        :date_of_birth, "Date of birth in `YYYY-MM-DD` format.",
        required: false
      )
      parameter(
        :iso_country_code, "The ISO 3166-1 alpha-2 country code of the phone number. It must be matched with the country of `msisdn` parameter.",
        required: false
      )
      parameter(
        :metadata, "Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format.",
        required: false
      )
      with_options scope: :address do
        parameter(
          :iso_region_code, "ISO 3166-2 of the country's subdivisions(e.g., provinces or states)",
          required: false
        )
        parameter(
          :administrative_division_level_2_code, "Code of administrative division level 2(e.g. district)",
          required: false
        )
        parameter(
          :administrative_division_level_2_name, "Name of administrative division level 2",
          required: false
        )
        parameter(
          :administrative_division_level_3_code, "Code of administrative division level 2(e.g. commune)",
          required: false
        )
        parameter(
          :administrative_division_level_3_name, "Name of administrative division level 3",
          required: false
        )
        parameter(
          :administrative_division_level_4_code, "Code of administrative division level 4(e.g. village)",
          required: false
        )
        parameter(
          :administrative_division_level_4_name, "Name of administrative division level 4",
          required: false
        )
      end
    end

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
