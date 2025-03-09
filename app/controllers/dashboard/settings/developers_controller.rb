module Dashboard
  module Settings
    class DevelopersController < Dashboard::BaseController
      private

      def association_chain
        current_account.access_tokens
      end
    end
  end
end
