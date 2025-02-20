require "rails_helper"

module CallFlowLogic
  RSpec.describe MamaInfoRegistration do
    it "plays an introduction" do
      event = create_delivery_attempt_event
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: event.delivery_attempt,
        event: event,
        current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(event.delivery_attempt.metadata.fetch("status")).to eq("playing_introduction")
      assert_play(audio_url(:introduction), response)
    end

    # Already registered flow

    it "handles users who are already registered" do
      beneficiary = create(:beneficiary, metadata: { date_of_birth: "2023-01-01" })
      delivery_attempt = create(:delivery_attempt, beneficiary: beneficiary, metadata: { status: :playing_introduction })
      event = create_delivery_attempt_event(delivery_attempt: delivery_attempt)
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event,
        current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(delivery_attempt.metadata.fetch("status")).to eq("playing_already_registered")
      assert_play(audio_url(:already_registered), response)
    end

    it "plays the registered date of birth (future)" do
      travel_to(Time.zone.local(2022, 6, 1)) do
        beneficiary = create(:beneficiary, metadata: { date_of_birth: "2023-01-01" })
        delivery_attempt = create(:delivery_attempt, beneficiary: beneficiary, metadata: { status: :playing_already_registered })
        event = create_delivery_attempt_event(delivery_attempt: delivery_attempt)
        call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
          delivery_attempt: delivery_attempt,
          event: event,
          current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
        )

        call_flow_logic.run!

        response = parse_response(call_flow_logic.to_xml)
        expect(delivery_attempt.metadata.fetch("status")).to eq("playing_registered_date_of_birth")
        expect(response.fetch("Play")).to eq(
          [
            audio_url(:confirm_pregnancy_status),
            audio_url(:january),
            audio_url("2023")
          ]
        )
      end
    end

    it "plays the registered date of birth (past)" do
      travel_to(Time.zone.local(2022, 6, 1)) do
        beneficiary = create(:beneficiary, metadata: { date_of_birth: "2022-01-01" })
        delivery_attempt = create(:delivery_attempt, beneficiary: beneficiary, metadata: { status: :playing_already_registered })
        event = create_delivery_attempt_event(delivery_attempt: delivery_attempt)
        call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
          delivery_attempt: delivery_attempt,
          event: event,
          current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
        )

        call_flow_logic.run!

        response = parse_response(call_flow_logic.to_xml)
        expect(delivery_attempt.metadata.fetch("status")).to eq("playing_registered_date_of_birth")
        expect(response.fetch("Play")).to eq(
          [
            audio_url(:confirm_age),
            audio_url(:january),
            audio_url("2022")
          ]
        )
      end
    end

    it "gathers whether to update details or deregister" do
      beneficiary = create(:beneficiary, metadata: { date_of_birth: "2022-01-01" })
      delivery_attempt = create(:delivery_attempt, beneficiary: beneficiary, metadata: { status: :playing_registered_date_of_birth })
      event = create_delivery_attempt_event(delivery_attempt: delivery_attempt)
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event,
        current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_update_details_or_deregister")
      assert_gather(audio_url(:gather_update_details_or_deregister), response)
    end

    it "updates the details" do
      beneficiary = create(:beneficiary, metadata: { date_of_birth: "2022-01-01" })
      delivery_attempt = create(:delivery_attempt, beneficiary: beneficiary, metadata: { status: :gathering_update_details_or_deregister })
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "1" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event,
        current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_mothers_status")
      assert_gather(audio_url(:gather_mothers_status), response)
    end

    it "deregisters the user" do
      beneficiary = create(:beneficiary, metadata: { date_of_birth: "2022-01-01" })
      delivery_attempt = create(:delivery_attempt, beneficiary: beneficiary, metadata: { status: :gathering_update_details_or_deregister })
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "2" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event,
        current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(delivery_attempt.metadata.fetch("status")).to eq("playing_deregistered")
      expect(beneficiary.metadata.fetch("deregistered_at")).to be_present
      expect(beneficiary.metadata.key?("date_of_birth")).to eq(false)
      assert_play(audio_url(:deregistration_successful), response)
    end

    it "handles invalid inputs" do
      beneficiary = create(:beneficiary, metadata: { date_of_birth: "2022-01-01" })
      delivery_attempt = create(:delivery_attempt, beneficiary: beneficiary, metadata: { status: :gathering_update_details_or_deregister })
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "3" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event,
        current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_update_details_or_deregister")
      assert_regather_invalid_response(audio_url(:gather_update_details_or_deregister), response)
    end

    it "gathers the mother's status" do
      delivery_attempt = create(:delivery_attempt, metadata: { status: :playing_introduction })
      event = create_delivery_attempt_event(delivery_attempt: delivery_attempt)
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event,
        current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_mothers_status")
      assert_gather(audio_url(:gather_mothers_status), response)
    end

    it "handles invalid inputs for mother's status" do
      delivery_attempt = create(:delivery_attempt, metadata: { status: :gathering_mothers_status })
      event = create_delivery_attempt_event(delivery_attempt: delivery_attempt)

      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_regather_invalid_response(audio_url(:gather_mothers_status), response)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_mothers_status")
    end

    it "allows mothers to listen again" do
      delivery_attempt = create(:delivery_attempt, metadata: { status: :gathering_mothers_status })
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "3" }
      )

      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather(audio_url(:gather_mothers_status), response)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_mothers_status")
    end

    # Pregnant flow

    it "gathers the pregnancy status" do
      delivery_attempt = create(:delivery_attempt, metadata: { status: :gathering_mothers_status })
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "1" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather(audio_url(:gather_pregnancy_status), response)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_pregnancy_status")
    end

    it "handles valid pregnancy status inputs" do
      travel_to(Time.zone.local(2022, 6, 1)) do
        delivery_attempt = create(:delivery_attempt, metadata: { status: :gathering_pregnancy_status })
        event = create_delivery_attempt_event(
          delivery_attempt: delivery_attempt,
          event_details: { Digits: "2" }
        )
        call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
          delivery_attempt: delivery_attempt,
          event: event
        )

        call_flow_logic.run!

        response = parse_response(call_flow_logic.to_xml)
        assert_gather(
          [
            audio_url(:confirm_pregnancy_status),
            audio_url(:january),
            audio_url("2023"),
            audio_url(:confirm_input)
          ],
          response
        )
        expect(delivery_attempt.metadata.fetch("unconfirmed_date_of_birth")).to eq("2023-01-01")
        expect(delivery_attempt.metadata.fetch("status")).to eq("confirming_pregnancy_status")
      end
    end

    it "handles invalid pregnancy status inputs" do
      delivery_attempt = create(:delivery_attempt, metadata: { status: :gathering_pregnancy_status })
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "10" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_regather_invalid_response(audio_url(:gather_pregnancy_status), response)
      expect(event.delivery_attempt.metadata.fetch("status")).to eq("gathering_pregnancy_status")
    end

    it "handles valid pregnancy status confirmation inputs" do
      delivery_attempt = create(
        :delivery_attempt,
        metadata: {
          status: :confirming_pregnancy_status,
          unconfirmed_date_of_birth: "2023-01-01"
        }
      )
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "1" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event,
        current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_play(audio_url(:registration_successful), response)
      expect(delivery_attempt.metadata.fetch("date_of_birth")).to eq("2023-01-01")
      expect(delivery_attempt.metadata.fetch("status")).to eq("playing_registration_successful")
      expect(delivery_attempt.beneficiary.metadata.fetch("date_of_birth")).to eq("2023-01-01")
    end

    it "handles invalid pregnancy status confirmation inputs" do
      delivery_attempt = create(
        :delivery_attempt,
        metadata: {
          status: :confirming_pregnancy_status
        }
      )
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "3" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_regather_invalid_response(audio_url(:confirm_pregnancy_status), response)
      expect(delivery_attempt.metadata.fetch("status")).to eq("confirming_pregnancy_status")
    end

    it "handles pregnancy status re-inputs" do
      delivery_attempt = create(
        :delivery_attempt,
        metadata: {
          status: :confirming_pregnancy_status
        }
      )
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "2" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather(audio_url(:gather_pregnancy_status), response)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_pregnancy_status")
    end

    # Child already born flow

    it "gathers the child's age" do
      delivery_attempt = create(:delivery_attempt, metadata: { status: :gathering_mothers_status })
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "2" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather(audio_url(:gather_age), response)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_age")
    end

    it "handles valid age inputs" do
      travel_to(Time.zone.local(2022, 6, 1)) do
        delivery_attempt = create(:delivery_attempt, metadata: { status: :gathering_age })
        event = create_delivery_attempt_event(
          delivery_attempt: delivery_attempt,
          event_details: { Digits: "6" }
        )
        call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
          delivery_attempt: delivery_attempt,
          event: event
        )

        call_flow_logic.run!

        response = parse_response(call_flow_logic.to_xml)
        assert_gather(
          [
            audio_url(:confirm_age),
            audio_url(:december),
            audio_url("2021"),
            audio_url(:confirm_input)
          ],
          response
        )
        expect(delivery_attempt.metadata.fetch("status")).to eq("confirming_age")
        expect(delivery_attempt.metadata.fetch("unconfirmed_date_of_birth")).to eq("2021-12-01")
      end
    end

    it "handles invalid age inputs" do
      delivery_attempt = create(:delivery_attempt, metadata: { status: :gathering_age })
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "100" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_regather_invalid_response(audio_url(:gather_age), response)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_age")
    end

    it "handles valid age confirmation inputs" do
      beneficiary = create(:beneficiary, metadata: { deregistered_at: Time.current })

      delivery_attempt = create(
        :delivery_attempt,
        :inbound,
        beneficiary: beneficiary,
        metadata: {
          status: :confirming_age,
          unconfirmed_date_of_birth: "2023-01-01"
        }
      )
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "1" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event,
        current_url: "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_play(audio_url(:registration_successful), response)
      expect(delivery_attempt.metadata.fetch("date_of_birth")).to eq("2023-01-01")
      expect(delivery_attempt.metadata.fetch("status")).to eq("playing_registration_successful")
      expect(delivery_attempt.beneficiary.metadata.fetch("date_of_birth")).to eq("2023-01-01")
      expect(delivery_attempt.beneficiary.metadata.key?("deregistered_at")).to eq(false)
    end

    it "handles invalid age confirmation inputs" do
      delivery_attempt = create(
        :delivery_attempt,
        metadata: {
          status: :confirming_age
        }
      )
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "3" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_regather_invalid_response(audio_url(:confirm_age), response)
      expect(delivery_attempt.metadata.fetch("status")).to eq("confirming_age")
    end

    it "handles age re-inputs" do
      delivery_attempt = create(
        :delivery_attempt,
        metadata: {
          status: :confirming_age
        }
      )
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt,
        event_details: { Digits: "2" }
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      assert_gather(audio_url(:gather_age), response)
      expect(delivery_attempt.metadata.fetch("status")).to eq("gathering_age")
    end

    it "finishes the call" do
      delivery_attempt = create(
        :delivery_attempt,
        metadata: {
          status: :playing_registration_successful
        }
      )
      event = create_delivery_attempt_event(
        delivery_attempt: delivery_attempt
      )
      call_flow_logic = CallFlowLogic::MamaInfoRegistration.new(
        delivery_attempt: delivery_attempt,
        event: event
      )

      call_flow_logic.run!

      response = parse_response(call_flow_logic.to_xml)
      expect(response).to have_key("Hangup")
      expect(delivery_attempt.metadata.fetch("status")).to eq("finished")
    end

    def create_delivery_attempt_event(options = {})
      delivery_attempt = options.fetch(:delivery_attempt) { create(:delivery_attempt) }
      default_event_details = attributes_for(:remote_phone_call_event).fetch(:details)
      details = options.fetch(:event_details, {}).reverse_merge(default_event_details)
      create(:remote_phone_call_event, delivery_attempt: delivery_attempt, details: details)
    end

    def parse_response(xml)
      Hash.from_xml(xml).fetch("Response")
    end

    def assert_play(filename, response)
      expect(response).to eq(
        "Play" => filename,
        "Redirect" => "https://scfm.somleng.org/twilio_webhooks/phone_call_events"
      )
    end

    def assert_gather(filename, response)
      expect(response.keys.size).to eq(1)
      expect(response.fetch("Gather")).to eq(
        "actionOnEmptyResult" => "true",
        "Play" => filename
      )
    end

    def assert_regather_invalid_response(filename, response)
      expect(response).to eq(
        "Play" => audio_url(:invalid_response),
        "Gather" => {
          "actionOnEmptyResult" => "true",
          "Play" => filename
        }
      )
    end

    def audio_url(filename)
      "https://s3.ap-southeast-1.amazonaws.com/audio.somleng.org/mama_info_registration/#{filename}-loz.mp3"
    end
  end
end
