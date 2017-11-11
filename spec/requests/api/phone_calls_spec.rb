require 'rails_helper'

RSpec.describe "Phone Calls" do
  include SomlengScfm::SpecHelpers::RequestHelpers
  let(:callout_participation) { create(:callout_participation) }
  let(:body) { {} }
  let(:factory_attributes) { {} }
  let(:phone_call) { create(:phone_call, factory_attributes) }

  def setup_scenario
    super
    do_request(method, url, body)
  end

  describe "GET '/phone_calls'" do
    let(:method) { :get }
    let(:url_params) { {} }
    let(:url) { api_phone_calls_path(url_params) }

    it_behaves_like "resource_filtering" do
      let(:filter_on_factory) { :phone_call }
    end

    it_behaves_like "authorization"
  end

  describe "POST '/api/callout_participation/:callout_participation_id/phone_calls'" do
    let(:method) { :post }
    let(:url) { api_callout_participation_phone_calls_path(callout_participation) }
    let(:metadata) { { "foo" => "bar"} }
    let(:body) { { :metadata => metadata } }
    let(:created_phone_call) { callout_participation.phone_calls.last }
    let(:parsed_response_body) { JSON.parse(response.body) }

    def assert_created!
      expect(response.code).to eq("201")
      expect(response.headers["Location"]).to eq(api_phone_call_path(created_phone_call))
      expect(parsed_response_body).to eq(JSON.parse(created_phone_call.to_json))
      expect(parsed_response_body["metadata"]).to eq(metadata)
    end

    it { assert_created! }
  end

  describe "'/api/phone_calls/:id'" do
    let(:url) { api_phone_call_path(phone_call) }

    describe "GET" do
      let(:method) { :get }

      def assert_show!
        expect(response.code).to eq("200")
        expect(JSON.parse(response.body)).to eq(JSON.parse(phone_call.to_json))
      end

      it { assert_show! }
    end

    describe "PATCH" do
      let(:method) { :patch }
      let(:metadata) { { "foo" => "bar" } }
      let(:body) { { :metadata => metadata } }

      def assert_update!
        expect(response.code).to eq("204")
        expect(phone_call.reload.metadata).to eq(metadata)
      end

      it { assert_update! }
    end

    describe "DELETE" do
      let(:method) { :delete }

      context "valid request" do
        def assert_destroy!
          expect(response.code).to eq("204")
          expect(PhoneCall.find_by_id(phone_call.id)).to eq(nil)
        end

        it { assert_destroy! }
      end

      context "invalid request" do
        let(:factory_attributes) { { :status => PhoneCall::STATE_QUEUED } }

        def assert_invalid!
          expect(response.code).to eq("422")
        end

        it { assert_invalid! }
      end
    end
  end

  describe "nested indexes" do
    let(:method) { :get }

    def setup_scenario
      create(:phone_call)
      phone_call
      super
    end

    def assert_filtered!
      expect(JSON.parse(response.body)).to eq(JSON.parse([phone_call].to_json))
    end

    describe "GET '/api/callout_participation/:callout_participation_id/phone_calls'" do
      let(:url) { api_callout_participation_phone_calls_path(callout_participation) }
      let(:factory_attributes) { { :callout_participation => callout_participation } }
      it { assert_filtered! }
    end

    describe "GET '/api/callout/:callout_id/phone_calls'" do
      let(:callout) { create(:callout) }
      let(:url) { api_callout_phone_calls_path(callout) }
      let(:factory_attributes) { { :callout => callout } }
      it { assert_filtered! }
    end

    describe "GET '/api/contact/:contact_id/phone_calls'" do
      let(:contact) { create(:contact) }
      let(:url) { api_contact_phone_calls_path(contact) }
      let(:factory_attributes) { { :contact => contact } }
      it { assert_filtered! }
    end
  end
end
