require "rails_helper"

RSpec.describe "Phone Calls" do
  it "can list all phone calls for an account" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account, status: PhoneCall::STATE_CREATED)
    other_phone_call = create(:phone_call)

    sign_in(user)
    visit(
      dashboard_phone_calls_path(
        q: { status: "created" }
      )
    )

    within("#filters") do
      expect(page).to have_link(
        "All",
        href: dashboard_phone_calls_path
      )

      expect(page).to have_link(
        "Created",
        href: dashboard_phone_calls_path(q: { status: "created" })
      )
    end

    expect(page).to have_title("Phone Calls")

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
      expect(page).to have_content("#")
      expect(page).to have_link(
        phone_call.id.to_s,
        href: dashboard_phone_call_path(phone_call)
      )
    end
  end

  it "can list all phone calls for a callout participation" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)
    other_phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_alert_phone_calls_path(phone_call.alert))

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
    end
  end

  it "can list all phone calls for a broadcast" do
    user = create(:user)
    alert = create_alert(account: user.account)
    phone_call = create_phone_call(
      account: user.account, alert:
    )
    other_phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_broadcast_phone_calls_path(alert.broadcast))

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
    end
  end

  it "can list all phone calls for a beneficiary" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)
    other_phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_beneficiary_phone_calls_path(phone_call.beneficiary))

    within("#resources") do
      expect(page).to have_content_tag_for(phone_call)
      expect(page).not_to have_content_tag_for(other_phone_call)
    end
  end

  it "can show a phone call" do
    user = create(:user)
    phone_call = create_phone_call(account: user.account)

    sign_in(user)
    visit(dashboard_phone_call_path(phone_call))

    within("#related_links") do
      expect(page).to have_link(
        "Phone Call Events",
        href: dashboard_phone_call_remote_phone_call_events_path(phone_call)
      )
    end

    within(".phone_call") do
      expect(page).to have_content(phone_call.id.to_s)

      expect(page).to have_link(
        phone_call.alert_id.to_s,
        href: dashboard_alert_path(phone_call.alert)
      )

      expect(page).to have_link(
        phone_call.broadcast_id.to_s,
        href: dashboard_broadcast_path(phone_call.broadcast_id)
      )

      expect(page).to have_link(
        phone_call.beneficiary_id.to_s,
        href: dashboard_beneficiary_path(phone_call.beneficiary_id)
      )
    end
  end
end
