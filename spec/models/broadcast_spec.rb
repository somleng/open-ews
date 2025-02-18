require "rails_helper"

RSpec.describe Broadcast do
  let(:factory) { :broadcast }
  include_examples "has_metadata"
  include_examples "has_call_flow_logic"

  describe "associations" do
    it { is_expected.to have_many(:alerts).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:batch_operations).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }

    context "#audio_file" do
      it "validates the content type" do
        broadcast = build(:broadcast, audio_file: file_fixture("image.jpg"))

        expect(broadcast).not_to be_valid
        expect(broadcast.errors[:audio_file]).to be_present
      end

      it "validates the file size" do
        broadcast = build(:broadcast, audio_file: file_fixture("big_file.mp3"))

        expect(broadcast).not_to be_valid
        expect(broadcast.errors[:audio_file]).to be_present
      end

      it "allows small audio files" do
        account = create(:account)
        broadcast = build(:broadcast, account: account, audio_file: file_fixture("test.mp3"))
        expect(broadcast).to be_valid
      end

      it "allows no audio files" do
        account = create(:account)
        broadcast = build(:broadcast, account: account)

        expect(broadcast).to be_valid
      end
    end
  end

  describe "audio_file=" do
    it "tracks changes when attaching a new audio file" do
      broadcast = described_class.new
      broadcast.audio_file = fixture_file_upload("test.mp3", "audio/mp3")

      expect(broadcast.audio_file_blob_changed?).to eq(true)
      expect(broadcast.audio_file_blob_was).to eq(nil)
    end

    it "tracks changes when updating the audio file" do
      broadcast = build(:broadcast, audio_file: file_fixture("test.mp3"))
      original_blob = broadcast.audio_file.blob
      broadcast.audio_file = fixture_file_upload("big_file.mp3", "audio/mp3")

      expect(broadcast.audio_file_blob_changed?).to eq(true)
      expect(broadcast.audio_file_blob_was).to eq(original_blob)
    end

    it "tracks changes when not updating the audio file" do
      broadcast = create(:broadcast, audio_file: file_fixture("test.mp3"))
      broadcast = Broadcast.find(broadcast.id)

      expect(broadcast.audio_file_blob_changed?).to eq(false)
    end
  end

  describe "state_machine" do
    subject { create(factory, factory_attributes) }

    def factory_attributes
      { status: current_status }
    end

    def assert_transitions!
      is_expected.to transition_from(current_status).to(asserted_new_status).on_event(event)
    end

    describe "#start!" do
      let(:current_status) { :pending }
      let(:asserted_new_status) { :running }
      let(:event) { :start }

      it { assert_transitions! }
    end

    describe "#stop!" do
      let(:current_status) { :running }
      let(:asserted_new_status) { :stopped }
      let(:event) { :stop }

      it { assert_transitions! }
    end

    describe "#resume!" do
      let(:current_status) { :stopped }
      let(:asserted_new_status) { :running }
      let(:event) { :resume }

      it { assert_transitions! }
    end

    describe "#complete!" do
      let(:current_status) { :running }
      let(:asserted_new_status) { :completed }
      let(:event) { :complete }

      it { assert_transitions! }
    end
  end
end
