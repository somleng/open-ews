require 'rails_helper'

RSpec.describe Event::Callout do
  let(:eventable_factory) { :broadcast }

  it_behaves_like("resource_event") do
    let(:event) { "start" }
    let(:asserted_current_status) { Broadcast::STATE_PENDING }
    let(:asserted_new_status) { Broadcast::STATE_RUNNING }
  end
end
