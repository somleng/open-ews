require "rails_helper"

RSpec.describe "Contacts", :aggregate_failures do
  it "can list all contacts" do
    user = create(:user)
    contact = create(:contact, account: user.account)
    other_contact = create(:contact)

    sign_in(user)
    visit dashboard_contacts_path

    expect(page).to have_title("Contacts")

    # TODO: Re-enable this once after data migration to native columns
    # within("#page_actions") do
    #   expect(page).to have_link("New", href: new_dashboard_contact_path)
    # end

    within("#resources") do
      expect(page).to have_content_tag_for(contact)
      expect(page).not_to have_content_tag_for(other_contact)
      expect(page).to have_content("#")
      expect(page).to have_link(
        contact.id.to_s,
        href: dashboard_contact_path(contact)
      )
    end
  end

  it "can delete a contact" do
    user = create(:user)
    contact = create(:contact, account: user.account)

    sign_in(user)
    visit dashboard_contact_path(contact)

    click_on "Delete"

    expect(page).to have_current_path(dashboard_contacts_path, ignore_query: true)
    expect(page).to have_text("Contact was successfully destroyed.")
  end

  it "can show a contact" do
    user = create(:user)
    phone_number = generate(:phone_number)
    contact = create(
      :contact,
      account: user.account,
      phone_number:,
      metadata: { "location" => { "country" => "Cambodia" } }
    )

    sign_in(user)
    visit dashboard_contact_path(contact)

    expect(page).to have_title("Contact #{contact.id}")

    # TODO: Re-enable this once after data migration to native columns
    # within("#page_actions") do
    #   expect(page).to have_link("Edit", href: edit_dashboard_contact_path(contact))
    # end

    within("#related_links") do
      expect(page).to have_link(
        "Callout Participations",
        href: dashboard_contact_callout_participations_path(contact)
      )

      expect(page).to have_link(
        "Phone Calls",
        href: dashboard_contact_phone_calls_path(contact)
      )
    end

    within(".contact") do
      expect(page).to have_content(contact.id)
      expect(page).to have_content("Cambodia")
    end
  end
end
