module Dashboard
  class CalloutEventsController < Dashboard::EventsController
    private

    def parent_resource
      broadcast
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(params[:broadcast_id])
    end

    def event_class
      Event::Callout
    end
  end
end
