module API
  class CalloutsController < API::BaseController
    private

    def find_resources_association_chain
      association_chain
    end

    def association_chain
      current_account.broadcasts.all
    end

    def filter_class
      Filter::Resource::Broadcast
    end

    def permitted_params
      params.permit(
        :call_flow_logic,
        :audio_url,
        :metadata_merge_mode,
        metadata: {},
        settings: {}
      )
    end

    def show_location(resource)
      api_callout_path(resource)
    end

    def resources_path
      api_callouts_path
    end
  end
end
