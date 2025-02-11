require "rails_helper"

RSpec.describe CallFlowLogic::PlayMessage do
  describe "#to_xml" do
    it "plays the audio url" do
      audio_url = "https://www.example.com/audio_url"
      broadcast = create(:broadcast, audio_url: audio_url, account: account)
      event = create_event(account: account, broadcast:)
      call_flow_logic = described_class.new(event: event)

      xml = call_flow_logic.to_xml

      response = Hash.from_xml(xml)["Response"]
      expect(response.keys.size).to eq(1)
      play_response = response.fetch("Play")
      expect(play_response).to eq(audio_url)
    end

    it "plays an error message if there is no audio url" do
      event = create_event(account: account)
      call_flow_logic = described_class.new(event: event)

      xml = call_flow_logic.to_xml

      response = Hash.from_xml(xml)["Response"]
      expect(response.keys.size).to eq(1)
      say_response = response.fetch("Say")
      expect(say_response).to eq("No audio URL to play. Bye Bye")
    end
  end

  let(:account) { create(:account) }

  def create_event(account:, **options)
    broadcast = options.delete(:broadcast)
    return create_remote_phone_call_event(account: account) unless broadcast
    callout_participation = create_callout_participation(account: account, broadcast:)
    phone_call = create_phone_call(account: account, callout_participation: callout_participation)
    create_remote_phone_call_event(account: account, phone_call: phone_call)
  end
end
