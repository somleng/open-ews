require "rails_helper"

RSpec.resource "Recordings" do
  header("Content-Type", "application/json")

  get "/api/recordings" do
    example "List Recordings" do
      account = create(:account)
      recording = create(:recording, account:)
      _old_recording = create(:recording, account:, created_at: 1.day.ago)
      _other_recording = create(:recording)

      set_authorization_header_for(account)
      do_request(
        q: {
          "created_at_or_after" => recording.created_at.iso8601
        }
      )

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(recording.id)
    end
  end

  get "/api/recordings/:id" do
    example "Retrieve a Recording" do
      account = create(:account)
      recording = create(:recording, account:)

      set_authorization_header_for(account)
      do_request(id: recording.id)

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.fetch("id")).to eq(recording.id)
    end
  end

  get "/api/recordings/:id.mp3" do
    example "Retrieve a recording as mp3" do
      account = create(:account)
      recording = create(:recording, account:)

      set_authorization_header_for(account)
      do_request(id: recording.id)

      expect(response_status).to eq(302)
      expect(response_headers["Location"]).to end_with(".mp3")
    end
  end
end
