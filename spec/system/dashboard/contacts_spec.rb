require "rails_helper"

RSpec.describe "Beneficiaries", :aggregate_failures do
  it "can list all beneficiaries" do
    user = create(:user)
    beneficiary = create(:beneficiary, account: user.account)
    other_beneficiary = create(:beneficiary)

    sign_in(user)
    visit dashboard_beneficiaries_path

    expect(page).to have_title("Contacts")

    # TODO: Re-enable this once after data migration to native columns
    # within("#page_actions") do
    #   expect(page).to have_link("New", href: new_dashboard_beneficiary_path)
    # end

    within("#resources") do
      expect(page).to have_content_tag_for(beneficiary)
      expect(page).not_to have_content_tag_for(other_beneficiary)
      expect(page).to have_content("#")
      expect(page).to have_link(
        beneficiary.id.to_s,
        href: dashboard_beneficiary_path(beneficiary)
      )
    end
  end

  it "can delete a beneficiary" do
    user = create(:user)
    beneficiary = create(:beneficiary, account: user.account)

    sign_in(user)
    visit dashboard_beneficiary_path(beneficiary)

    click_on "Delete"

    expect(page).to have_current_path(dashboard_beneficiaries_path, ignore_query: true)
    expect(page).to have_text("Contact was successfully destroyed.")
  end

  it "can show a beneficiary" do
    user = create(:user)
    phone_number = generate(:phone_number)
    beneficiary = create(
      :beneficiary,
      account: user.account,
      phone_number:,
      metadata: { "location" => { "country" => "Cambodia" } }
    )

    sign_in(user)
    visit dashboard_beneficiary_path(beneficiary)

    expect(page).to have_title("Contact #{beneficiary.id}")

    # TODO: Re-enable this once after data migration to native columns
    # within("#page_actions") do
    #   expect(page).to have_link("Edit", href: edit_dashboard_beneficiary_path(beneficiary))
    # end

    within("#related_links") do
      expect(page).to have_link(
        "Callout Participations",
        href: dashboard_beneficiary_alerts_path(beneficiary)
      )

      expect(page).to have_link(
        "Phone Calls",
        href: dashboard_beneficiary_delivery_attempts_path(beneficiary)
      )
    end

    within(".beneficiary") do
      expect(page).to have_content(beneficiary.id)
      expect(page).to have_content("Cambodia")
    end
  end
end
