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
      do_request(filter: { status: "active" })

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
    with_options scope: %i[data] do
      parameter(
        :type, "Must be `beneficiary`",
        required: true
      )
    end
    with_options scope: %i[data attributes] do
      parameter(
        :phone_number, "Phone number in E.164 format.",
        required: true
      )
      parameter(
        :iso_country_code, "The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the beneficiary.",
        required: true
      )
      parameter(
        :language_code, "The [ISO ISO 639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes) alpha-3 language code of the beneficiary.",
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
        :metadata, "Set of key-value pairs that you can attach to the beneficiary. This can be useful for storing additional information about the beneficiary in a structured format.",
        required: false
      )
    end
    with_options scope: %i[data attributes address] do
      parameter(
        :iso_country_code, "The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the address",
        required: false
      )
      parameter(
        :iso_region_code, "The [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) region code of the address",
        required: false
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

    example "Create a beneficiary" do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :beneficiary,
          attributes: {
            phone_number: "+85510999999",
            language_code: "khm",
            gender: "M",
            date_of_birth: "1990-01-01",
            metadata: { "foo" => "bar" },
            iso_country_code: "KH",
            address: {
              iso_country_code: "KH",
              iso_region_code: "KH-1",
              administrative_division_level_2_code: "0102",
              administrative_division_level_2_name: "Mongkol Borei",
              administrative_division_level_3_code: "010201",
              administrative_division_level_3_name: "Banteay Neang",
              administrative_division_level_4_code: "01020101",
              administrative_division_level_4_name: "Ou Thum"
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(jsonapi_response_attributes).to include(
        "phone_number" => "+85510999999",
        "language_code" => "khm",
        "gender" => "M",
        "date_of_birth" => "1990-01-01",
        "metadata" => { "foo" => "bar" },
        "iso_country_code" => "KH",
      )

      expect(json_response.dig("included", 0).to_json).to match_api_response_schema("address")
      expect(json_response.dig("included", 0, "attributes")).to include(
        "iso_region_code" => "KH-1",
        "administrative_division_level_2_code" => "0102",
        "administrative_division_level_2_name" => "Mongkol Borei",
        "administrative_division_level_3_code" => "010201",
        "administrative_division_level_3_name" => "Banteay Neang",
        "administrative_division_level_4_code" => "01020101",
        "administrative_division_level_4_name" => "Ou Thum"
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
            phone_number: "+85510999999",
            iso_country_code: "KH"
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0)).to include(
        "title" => "must be unique",
        "source" => { "pointer" => "/data/attributes/phone_number" }
      )
    end
  end

  get "/v1/beneficiaries/:id" do
    example "Fetch a beneficiary" do
      beneficiary = create(:beneficiary)

      set_authorization_header_for(beneficiary.account)
      do_request(id: beneficiary.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(json_response.dig("data", "id")).to eq(beneficiary.id.to_s)
    end
  end

  patch "/v1/beneficiaries/:id" do
    with_options scope: %i[data] do
      parameter(
        :id, "The unique identifier of the beneficiary.",
        required: true
      )
      parameter(
        :type, "Must be `beneficiary`",
        required: true
      )
    end

    with_options scope: %i[data attributes] do
      parameter(
        :phone_number, "Phone number in E.164 format.",
        required: false
      )
      parameter(
        :iso_country_code, "The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the beneficiary.",
        required: false
      )
      parameter(
        :language_code, "The [ISO ISO 639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes) alpha-3 language code of the beneficiary.",
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
        :metadata, "Set of key-value pairs that you can attach to the beneficiary. This can be useful for storing additional information about the beneficiary in a structured format.",
        required: false
      )
    end

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
            phone_number: "+85510999002",
            gender: "F",
            status: "disabled",
            language_code: "eng",
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
        "phone_number" => "+85510999002",
        "language_code" => "eng",
        "gender" => "F",
        "date_of_birth" => "1990-01-01",
        "metadata" => { "foo" => "bar" }
      )
    end
  end
end
