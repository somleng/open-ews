require "rails_helper"

RSpec.describe "Phone Calls" do
  it "can list all phone calls for an account" do
    user = create(:user)
    delivery_attempt = create_delivery_attempt(account: user.account, status: DeliveryAttempt::STATE_CREATED)
    other_delivery_attempt = create(:delivery_attempt)

    sign_in(user)
    visit(
      dashboard_delivery_attempts_path(
        q: { status: "created" }
      )
    )

    within("#filters") do
      expect(page).to have_link(
        "All",
        href: dashboard_delivery_attempts_path
      )

      expect(page).to have_link(
        "Created",
        href: dashboard_delivery_attempts_path(q: { status: "created" })
      )
    end

    expect(page).to have_title("Phone Calls")

    within("#resources") do
      expect(page).to have_content_tag_for(delivery_attempt)
      expect(page).not_to have_content_tag_for(other_delivery_attempt)
      expect(page).to have_content("#")
      expect(page).to have_link(
        delivery_attempt.id.to_s,
        href: dashboard_delivery_attempt_path(delivery_attempt)
      )
    end
  end

  it "can list all phone calls for a callout participation" do
    user = create(:user)
    delivery_attempt = create_delivery_attempt(account: user.account)
    other_delivery_attempt = create_delivery_attempt(account: user.account)

    sign_in(user)
    visit(dashboard_alert_delivery_attempts_path(delivery_attempt.alert))

    within("#resources") do
      expect(page).to have_content_tag_for(delivery_attempt)
      expect(page).not_to have_content_tag_for(other_delivery_attempt)
    end
  end

  it "can list all phone calls for a broadcast" do
    user = create(:user)
    alert = create_alert(account: user.account)
    delivery_attempt = create_delivery_attempt(
      account: user.account, alert:
    )
    other_delivery_attempt = create_delivery_attempt(account: user.account)

    sign_in(user)
    visit(dashboard_broadcast_delivery_attempts_path(alert.broadcast))

    within("#resources") do
      expect(page).to have_content_tag_for(delivery_attempt)
      expect(page).not_to have_content_tag_for(other_delivery_attempt)
    end
  end

  it "can list all phone calls for a beneficiary" do
    user = create(:user)
    delivery_attempt = create_delivery_attempt(account: user.account)
    other_delivery_attempt = create_delivery_attempt(account: user.account)

    sign_in(user)
    visit(dashboard_beneficiary_delivery_attempts_path(delivery_attempt.beneficiary))

    within("#resources") do
      expect(page).to have_content_tag_for(delivery_attempt)
      expect(page).not_to have_content_tag_for(other_delivery_attempt)
    end
  end

  it "can show a phone call" do
    user = create(:user)
    delivery_attempt = create_delivery_attempt(account: user.account)

    sign_in(user)
    visit(dashboard_delivery_attempt_path(delivery_attempt))

    within("#related_links") do
      expect(page).to have_link(
        "Phone Call Events",
        href: dashboard_delivery_attempt_remote_phone_call_events_path(delivery_attempt)
      )
    end

    within(".delivery_attempt") do
      expect(page).to have_content(delivery_attempt.id.to_s)

      expect(page).to have_link(
        delivery_attempt.alert_id.to_s,
        href: dashboard_alert_path(delivery_attempt.alert)
      )

      expect(page).to have_link(
        delivery_attempt.broadcast_id.to_s,
        href: dashboard_broadcast_path(delivery_attempt.broadcast_id)
      )

      expect(page).to have_link(
        delivery_attempt.beneficiary_id.to_s,
        href: dashboard_beneficiary_path(delivery_attempt.beneficiary_id)
      )
    end
  end
end
