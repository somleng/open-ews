module Dashboard
  module Settings
    class UsersController < Dashboard::BaseController
      private

      def association_chain
        current_account.users
      end
    end
  end
end
