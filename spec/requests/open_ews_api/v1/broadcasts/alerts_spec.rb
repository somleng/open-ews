require "rails_helper"

RSpec.resource "Broadcasts"  do
  get "/v1/broadcasts/:broadcast_id/alerts" do
    with_options scope: :filter do
      FieldDefinitions::AlertFields.each do |field|
        parameter(field.name, field.description, required: false, method: :_disabled)
      end
    end

    example "List all alerts for a broadcast" do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      alerts = create_list(:alert, 3, broadcast: broadcast)
      _other_alert = create(:alert)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("alert")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        *alerts.map(&:id).map(&:to_s)
      )
    end


    example "List all alerts for a broadcast with filters", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      completed_alerts = create_list(:alert, 2, status: :completed, broadcast: broadcast)
      _queued_alerts = create(:alert, status: :queued, broadcast: broadcast)
      _other_alert = create(:alert)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id, filter: { status: { eq: "completed" } })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("alert")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        *completed_alerts.map(&:id).map(&:to_s)
      )
    end

    example "List all alerts for a broadcast with beneficiary filters", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      male = create(:beneficiary, gender: "M")
      female = create(:beneficiary, gender: "F")
      _male_beneficiary_alert = create(:alert, beneficiary: male, broadcast: broadcast)
      female_beneficiary_alert = create(:alert, beneficiary: female, broadcast: broadcast)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id, filter: { "beneficiary.gender": { eq: "F" } })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("alert")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        female_beneficiary_alert.id.to_s
      )
    end

    example "List all alerts for a broadcast include their associations", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      create_list(:alert, 2, broadcast: broadcast)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id, include: "beneficiary,broadcast")

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("alert")
      expect(json_response.fetch("included").pluck("type").uniq).to contain_exactly(
        "beneficiary", "broadcast"
      )
    end
  end

  get "/v1/broadcasts/:broadcast_id/alerts/:id" do
    example "Get an alert" do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      alert = create(:alert, broadcast: broadcast)

      set_authorization_header_for(account)
      do_request(id: alert.id, broadcast_id: broadcast.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("alert")
      expect(json_response.dig("data", "id")).to eq(alert.id.to_s)
    end
  end

  get "/v1/broadcasts/:broadcast_id/alerts/stats" do
    with_options scope: :filter do
      FieldDefinitions::AlertFields.each do |field|
        parameter(field.name, field.description, required: false, method: :_disabled)
      end
    end

    parameter(
      :group_by,
      "An array of fields to group by. Supported fields: #{V1::BeneficiaryStatsRequestSchema::GROUPS.map { |group| "`#{group}`" }.join(", ")}.",
      required: true
    )

    example "Fetch alerts stats" do
      explanation <<~HEREDOC
        This endpoint provides statistical insights into the alerts under a broadcast managed within the OpenEWS system. This endpoint is particularly useful for generating reports, analyzing alert data, and monitoring the scope of your early warning system.

        ### Functionality

        This endpoint returns aggregated statistics about the alerts under a broadcast in your system. Common use cases include:

        - Counting the total number of alerts.
        - Grouping beneficiaries by attributes such as location or gender.
        - Identifying trends or patterns in alert data.

        ### Parameters

        The endpoint may accept query parameters to filter or group the data. Common parameters include:

        - **Filters:** Specify conditions for narrowing down the results. For example, you might filter alerts by a specific status or beneficiary's fields.
        - **Group By:** Group the statistics by a particular attribute such as `status`, or beneficiary's fields.
      HEREDOC

      account = create(:account)
      broadcast = create(:broadcast, account:)
      male1_beneficiary = create(:beneficiary, account:, gender: "M")
      male2_beneficiary = create(:beneficiary, account:, gender: "M")
      male3_beneficiary = create(:beneficiary, account:, gender: "M")
      female1_beneficiary = create(:beneficiary, account:, gender: "F")
      female2_beneficiary = create(:beneficiary, account:, gender: "F")
      create(:alert, broadcast:, status: :completed, beneficiary: male1_beneficiary)
      create(:alert, broadcast:, status: :completed, beneficiary: male2_beneficiary)
      create(:alert, broadcast:, status: :failed, beneficiary: male3_beneficiary)
      create(:alert, broadcast:, status: :completed, beneficiary: female1_beneficiary)
      create(:alert, broadcast:, status: :completed, beneficiary: female2_beneficiary)

      set_authorization_header_for(account)
      do_request(
        broadcast_id: broadcast.id,
        filter: { "status": { eq: "completed" } },
        group_by: [
          "beneficiary.gender"
        ]
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("stat", pagination: false)
      results = json_response.fetch("data").map { |data| data.dig("attributes", "result") }

      expect(results).to match_array(
        [
          {
            "beneficiary.gender" => "M",
            "value" => 2
          },
          {
            "beneficiary.gender" => "F",
            "value" => 2
          }
        ]
      )
    end
  end
end
