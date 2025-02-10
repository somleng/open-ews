module Dashboard
  class BeneficiariesController < Dashboard::BaseController
    private

    def association_chain
      current_account.beneficiaries
    end

    def build_key_value_fields
      build_metadata_field
    end
  end
end
