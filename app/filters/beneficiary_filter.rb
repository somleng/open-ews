class BeneficiaryFilter < ResourceFilter
  class StatusFilter < ApplicationFilter
    filter_params do
      optional(:status).value(:string, included_in?: Contact.status.values)
    end

    def apply
      super.where(status: filter_params.fetch(:status, :active))
    end
  end

  filter_with StatusFilter, :date_filter
end
