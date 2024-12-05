require "rails_helper"

RSpec.resource "Contacts"  do
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

  post "/v1/contacts" do
    example "Create a contact" do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :contact,
          attributes: {
            msisdn: "+85510999999",
            language_code: "km",
            gender: "m",
            date_of_birth: "1990-01-01"
          }
        }
      )

      expect(response_status).to eq(201)
    end

    example "Fail to create a contact", document: false do
      account = create(:account)
      create(:contact, account:, msisdn: "+85510999999")

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :contact,
          attributes: {
            msisdn: "+85510999999"
          }
        }
      )

      expect(response_status).to eq(422)
    end
  end
end
