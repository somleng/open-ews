
require "rails_helper"

RSpec.resource "JSONAPI", document: false  do
  get "/v1/beneficiaries/:id" do
    it "supports include related resources" do
      beneficiary = create(:beneficiary)
      create(:beneficiary_address, beneficiary:)

      set_authorization_header_for(beneficiary.account)
      do_request(id: beneficiary.id, include: "addresses")

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(json_response.dig("included", 0).to_json).to match_api_response_schema("address")
    end

    it "handles passing an invalid related resource" do
      beneficiary = create(:beneficiary)
      create(:beneficiary_address, beneficiary:)

      set_authorization_header_for(beneficiary.account)
      do_request(id: beneficiary.id, include: "foobar")

      expect(response_status).to eq(400)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0, "source", "pointer")).to eq("/include")
    end
  end
end
