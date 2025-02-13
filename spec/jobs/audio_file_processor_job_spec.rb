require "rails_helper"

RSpec.describe AudioFileProcessorJob do
  it "uploads the broadcast voice url to a public bucket", :active_storage do
    broadcast = create(:broadcast, audio_file: file_fixture("test.mp3"))

    s3 = Aws::S3::Resource.new(stub_responses: true)
    allow(Aws::S3::Resource).to receive(:new).and_return(s3)

    stub_request(:get, /example\.com/).to_return(body: "hello world")

    AudioFileProcessorJob.perform_now(broadcast)

    broadcast.reload
    expect(broadcast.audio_url).to be_present
    expect(broadcast.audio_url).to include("test.mp3")
  end
end
