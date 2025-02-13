module API
  class CalloutEventsController < API::ResourceEventsController
    private

    def parent_resource
      broadcast
    end

    def path_to_parent
      api_callout_path(broadcast)
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(params[:callout_id])
    end

    def event_class
      Event::Callout
    end

    def access_token_write_permissions
      [ :callouts_write ]
    end
  end
end
