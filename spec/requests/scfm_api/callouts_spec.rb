require "rails_helper"

RSpec.resource "Callouts" do
  header("Content-Type", "application/json")

  get "/api/callouts" do
    example "List all Callouts" do
      filtered_broadcast = create(
        :broadcast,
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )
      create(:broadcast, account: account)
      create(:broadcast)

      set_authorization_header_for(account)
      do_request(
        q: {
          "metadata" => { "foo" => "bar" }
        }
      )

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(filtered_broadcast.id)
    end
  end

  post "/api/callouts" do
    parameter(
      :call_flow_logic,
      "The name of the call flow logic to be run during the callout."
    )

    parameter(
      :audio_url,
      "The URL to an audio file to be played during the callout."
    )

    parameter(
      :settings,
      "Additional settings which are needed by the call flow logic."
    )

    example "Create a Callout" do
      request_body = {
        call_flow_logic: CallFlowLogic::HelloWorld.to_s,
        audio_url: "https://www.example.com/sample.mp3",
        metadata: {
          "foo" => "bar"
        },
        settings: {
          "external_service_1" => {
            "foo" => "bar"
          }
        }
      }

      set_authorization_header_for(account)
      do_request(request_body)

      expect(response_status).to eq(201)
      parsed_response = JSON.parse(response_body)
      created_broadcast = account.broadcasts.find(parsed_response.fetch("id"))
      expect(created_broadcast.metadata).to eq(request_body.fetch(:metadata))
      expect(created_broadcast.settings).to eq(request_body.fetch(:settings))
      expect(created_broadcast.call_flow_logic).to eq(request_body.fetch(:call_flow_logic))
      expect(created_broadcast.audio_url).to eq(request_body.fetch(:audio_url))
      expect(parsed_response.fetch("status")).to eq("initialized")
    end
  end

  get "/api/callouts/:id" do
    example "Retrieve a Callout" do
      broadcast = create(:broadcast, account: account)

      set_authorization_header_for(account)
      do_request(id: broadcast.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.broadcasts.find(parsed_response.fetch("id"))
      ).to eq(broadcast)
    end
  end

  patch "/api/callouts/:id" do
    example "Update a Callout" do
      broadcast = create(
        :broadcast,
        account: account,
        metadata: {
          "foo" => "bar"
        }
      )

      request_body = { metadata: { "bar" => "foo" }, metadata_merge_mode: "replace" }

      set_authorization_header_for(account)
      do_request(id: broadcast.id, **request_body)

      expect(response_status).to eq(204)
      broadcast.reload
      expect(broadcast.metadata).to eq(request_body.fetch(:metadata))
    end
  end

  delete "/api/callouts/:id" do
    example "Delete a Callout" do
      broadcast = create(:broadcast, account: account)

      set_authorization_header_for(account)
      do_request(id: broadcast.id)

      expect(response_status).to eq(204)
      expect(Broadcast.find_by_id(broadcast.id)).to eq(nil)
    end

    example "Delete a Callout with callout participations", document: false do
      broadcast = create(:broadcast, account: account)
      _callout_participation = create_alert(
        account: account, broadcast: broadcast
      )

      set_authorization_header_for(account)
      do_request(id: broadcast.id)

      expect(response_status).to eq(422)
    end
  end

  post "/api/callouts/:callout_id/callout_events" do
    parameter(
      :event,
      "One of: " + Broadcast.aasm.events.map { |event| "`#{event.name}`" }.join(", "),
      required: true
    )

    example "Create a Callout Event" do
      broadcast = create(
        :broadcast,
        account: account,
        status: Broadcast::STATE_PENDING
      )

      set_authorization_header_for(account)
      do_request(callout_id: broadcast.id, event: "start")

      expect(response_status).to eq(201)
      expect(response_headers["Location"]).to eq(api_callout_path(broadcast))
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.fetch("status")).to eq("running")
      expect(broadcast.reload).to be_running
    end

    example "Start a running Callout", document: false do
      broadcast = create(
        :broadcast,
        account: account,
        status: Broadcast::STATE_RUNNING
      )

      set_authorization_header_for(account)
      do_request(callout_id: broadcast.id, event: "start")

      expect(response_status).to eq(422)
    end
  end

  get "/api/callouts/:callout_id/batch_operations" do
    example "List all Callout Batch Operations", document: false do
      broadcast = create(:broadcast, account: account)
      callout_population = create(:callout_population, broadcast: broadcast, account: account)

      set_authorization_header_for(account)
      do_request(callout_id: broadcast.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.batch_operations.find(parsed_response.first.fetch("id"))
      ).to eq(callout_population)
    end
  end

  let(:account) { create(:account) }
end
