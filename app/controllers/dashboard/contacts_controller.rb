module Dashboard
  class ContactsController < Dashboard::BaseController
    private

    def association_chain
      current_account.contacts
    end

    def build_key_value_fields
      build_metadata_field
    end
  end
end
