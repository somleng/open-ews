module Dashboard
  class BroadcastsController < Dashboard::BaseController
    helper_method :broadcast_summary

    private

    def association_chain
      current_account.broadcasts
    end

    def permitted_params
      params.fetch(:broadcast, {}).permit(
        :call_flow_logic,
        :audio_file,
        :audio_url,
        settings_fields_attributes: KEY_VALUE_FIELD_ATTRIBUTES,
        **METADATA_FIELDS_ATTRIBUTES
      )
    end

    def before_update_attributes
      clear_metadata
      resource.settings.clear
    end

    def build_key_value_fields
      build_metadata_field
      resource.build_settings_field if resource.settings_fields.empty?
    end

    def prepare_resource_for_create
      resource.created_by ||= current_user
    end

    def broadcast_summary
      @broadcast_summary ||= BroadcastSummary.new(resource)
    end
  end
end
