require "rails_helper"

RSpec.describe "Alerts" do
  it "can list all alerts for an account" do
    user = create(:user)
    alert = create_alert(account: user.account)
    running_alert = create_alert(
      account: user.account, broadcast: create(:broadcast, :running, account: user.account)
    )
    other_alert = create(:alert)

    sign_in(user)
    visit(
      dashboard_alerts_path(q: { callout_filter_params: { status: :pending } })
    )

    expect(page).to have_title("Callout Participations")

    within("#resources") do
      expect(page).to have_content_tag_for(alert)
      expect(page).not_to have_content_tag_for(other_alert)
      expect(page).not_to have_content_tag_for(running_alert)
      expect(page).to have_content("#")
      expect(page).to have_content("Contact")
      expect(page).to have_content("Callout")
      expect(page).to have_link(
        alert.id.to_s,
        href: dashboard_alert_path(alert)
      )
      expect(page).to have_link(
        alert.beneficiary_id.to_s,
        href: dashboard_beneficiary_path(alert.beneficiary)
      )
      expect(page).to have_link(
        alert.broadcast_id.to_s,
        href: dashboard_broadcast_path(alert.broadcast)
      )
    end
  end

  it "can list all alerts for a broadcast" do
    user = create(:user)
    alert = create_alert(account: user.account)
    other_alert = create_alert(account: user.account)

    sign_in(user)
    visit(dashboard_broadcast_alerts_path(alert.broadcast))

    expect(page).to have_title("Callout Participations")

    within("#resources") do
      expect(page).to have_content_tag_for(alert)
      expect(page).not_to have_content_tag_for(other_alert)
    end
  end

  it "can list all the alerts for a beneficiary" do
    user = create(:user)
    alert = create_alert(account: user.account)
    other_alert = create_alert(account: user.account)

    sign_in(user)
    visit(dashboard_beneficiary_alerts_path(alert.beneficiary))

    expect(page).to have_title("Callout Participations")

    within("#resources") do
      expect(page).to have_content_tag_for(alert)
      expect(page).not_to have_content_tag_for(other_alert)
    end
  end

  it "can show a alert" do
    user = create(:user)
    callout_population = create(:callout_population, account: user.account)
    alert = create_alert(
      account: user.account,
      broadcast: callout_population.broadcast,
      callout_population:
    )

    sign_in(user)
    visit(dashboard_alert_path(alert))

    expect(page).to have_title("Callout Participation #{alert.id}")

    within("#related_links") do
      expect(page).to have_link(
        "Phone Calls",
        href: dashboard_alert_delivery_attempts_path(alert)
      )
    end

    within(".alert") do
      expect(page).to have_content(alert.id)

      expect(page).to have_link(
        alert.broadcast_id.to_s,
        href: dashboard_broadcast_path(alert.broadcast)
      )

      expect(page).to have_link(
        alert.beneficiary_id.to_s,
        href: dashboard_beneficiary_path(alert.beneficiary)
      )

      expect(page).to have_link(
        alert.callout_population_id.to_s,
        href: dashboard_batch_operation_path(alert.callout_population)
      )

      expect(page).to have_content("Callout")
      expect(page).to have_content("Contact")
      expect(page).to have_content("Callout population")
      expect(page).to have_content("Created at")
    end
  end

  it "can delete a alert" do
    user = create(:user)
    alert = create_alert(account: user.account)

    sign_in(user)
    visit dashboard_alert_path(alert)

    click_on "Delete"

    expect(page).to have_current_path(dashboard_alerts_path, ignore_query: true)
    expect(page).to have_text("was successfully destroyed")
  end
end
