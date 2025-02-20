module CallFlowLogic
  class PlayMessageStartRapidproFlow < CallFlowLogic::PlayMessage
    def run!
      super
      return unless event.delivery_attempt.completed?

      ExecuteWorkflowJob.perform_later(StartRapidproFlow.to_s, event.delivery_attempt)
    end
  end
end
