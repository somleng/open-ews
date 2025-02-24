require "rails_helper"

RSpec.describe "Callouts", :aggregate_failures do
  it "can list broadcasts" do
    user          = create(:user)
    broadcast       = create(
      :broadcast,
      :pending,
      call_flow_logic: CallFlowLogic::HelloWorld,
      account: user.account
    )
    other_broadcast = create(:broadcast)

    sign_in(user)
    visit dashboard_broadcasts_path

    expect(page).to have_title("Callouts")

    within("#page_actions") do
      expect(page).to have_link("New", href: new_dashboard_broadcast_path)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(broadcast)
      expect(page).not_to have_content_tag_for(other_broadcast)
      expect(page).to have_content("#")
      expect(page).to have_link(
        broadcast.id.to_s,
        href: dashboard_broadcast_path(broadcast)
      )
      expect(page).to have_content("Hello World")
    end
  end

  it "create and start a broadcast", :js do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_broadcast_path

    expect(page).to have_title("New Callout")

    fill_in("Audio URL", with: "https://www.example.com/sample.mp3")
    choose("Hello World")

    fill_in_key_values_for(
      :metadata,
      with: {
        "location:country" => "kh"
      }
    )

    fill_in_key_values_for(
      :settings,
      with: {
        "rapidpro:flow_id" => "flow-id"
      }
    )

    expect { click_on("Create Callout") }.not_to have_enqueued_job(AudioFileProcessorJob)

    expect(page).to have_content("Callout was successfully created.")
    expect(page).to have_content(
      JSON.pretty_generate(
        "location" => { "country" => "kh" }
      )
    )
    expect(page).to have_content(
      JSON.pretty_generate(
        "rapidpro" => { "flow_id" => "flow-id" }
      )
    )
  end

  it "can create a broadcast attaching an audio file" do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_broadcast_path

    attach_file("Audio file", Rails.root + file_fixture("test.mp3"))
    choose("Hello World")
    expect { click_on("Create Callout") }.to have_enqueued_job(AudioFileProcessorJob)

    expect(page).to have_content("Callout was successfully created.")
  end

  it "can update a broadcast", :js do
    user = create(:user)
    broadcast = create(
      :broadcast,
      account: user.account,
      metadata: { "location" => { "country" => "kh", "city" => "Phnom Penh" } },
      settings: { "rapidpro" => { "flow_id" => "flow-id" } }
    )

    sign_in(user)
    visit edit_dashboard_broadcast_path(broadcast)

    expect(page).to have_title("Edit Callout")

    choose("Hello World")
    remove_key_value_for(:metadata)
    remove_key_value_for(:metadata)
    remove_key_value_for(:settings)
    click_on "Save"

    expect(page).to have_text("Callout was successfully updated.")
    expect(broadcast.reload.metadata).to eq({})
    expect(broadcast.reload.settings).to eq({})
    expect(broadcast.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
  end

  it "can delete a broadcast" do
    user = create(:user)
    broadcast = create(:broadcast, account: user.account)

    sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    click_on "Delete"

    expect(page).to have_current_path(dashboard_broadcasts_path, ignore_query: true)
    expect(page).to have_text("Callout was successfully destroyed.")
  end

  it "can show a broadcast" do
    user = create(:user)
    broadcast = create(
      :broadcast,
      :pending,
      account: user.account,
      call_flow_logic: CallFlowLogic::HelloWorld,
      created_by: user,
      audio_file: file_fixture("test.mp3"),
      audio_url: "https://example.com/audio.mp3",
      metadata: { "location" => { "country" => "Cambodia" } },
      settings: { "rapidpro" => { "flow_id" => "flow-id" } }
    )

    sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    expect(page).to have_title("Callout #{broadcast.id}")

    within("#page_actions") do
      expect(page).to have_link("Edit", href: edit_dashboard_broadcast_path(broadcast))
    end

    within("#related_links") do
      expect(page).to have_link(
        "Callout Populations",
        href: dashboard_broadcast_batch_operations_path(broadcast)
      )

      expect(page).to have_link(
        "Callout Participations",
        href: dashboard_broadcast_alerts_path(broadcast)
      )
      expect(page).to have_link(
        "Phone Calls",
        href: dashboard_broadcast_delivery_attempts_path(broadcast)
      )
    end

    within(".broadcast") do
      expect(page).to have_content(broadcast.id)
      expect(page).to have_link(broadcast.audio_url, href: broadcast.audio_url)
      expect(page).to have_link(
        broadcast.created_by_id.to_s,
        href: dashboard_user_path(broadcast.created_by)
      )
    end

    within("#broadcast_summary") do
      expect(page).to have_content("Callout Summary")
      expect(page).to have_link("Refresh", href: dashboard_broadcast_path(broadcast))
      expect(page).to have_content("Participants")
      expect(page).to have_content("Participants still to be called")
      expect(page).to have_content("Completed calls")
      expect(page).to have_content("Busy calls")
      expect(page).to have_content("Not answered calls")
      expect(page).to have_content("Failed calls")
      expect(page).to have_content("Errored calls")
    end
  end

  it "can perform actions on broadcasts", :js do
    user = create(:user)
    broadcast = create(:broadcast, :pending, account: user.account)

    sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    click_on("Start")

    expect(page).to have_content("Event was successfully created.")
    expect(page).not_to have_selector(:link_or_button, "Start")
    expect(page).to have_selector(:link_or_button, "Stop")

    click_on("Stop")

    expect(page).to have_content("Event was successfully created.")
    expect(page).not_to have_selector(:link_or_button, "Stop")
    expect(page).to have_selector(:link_or_button, "Resume")

    click_on("Resume")

    expect(page).not_to have_selector(:link_or_button, "Resume")
    expect(page).to have_selector(:link_or_button, "Stop")
  end
end
