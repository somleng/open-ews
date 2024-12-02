require "rails_helper"

RSpec.resource "Contacts"  do
  header "Host", "api.open-ews.org"

  get "/v1/contacts" do
    example "List all Contacts" do
      account = create(:account)
      account_contact = create(:contact, account:)
      _other_account_contact = create(:contact)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("contact")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        account_contact.id.to_s
      )
    end
  end
end
