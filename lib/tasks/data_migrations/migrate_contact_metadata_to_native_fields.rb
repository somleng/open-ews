module Subdivisions
  Province = Struct.new(:code, :iso3166, :name_en, keyword_init: true)

  ZAMBIA_PROVINCES = [
    Province.new(code: "ZM-02", iso3166: "ZM-02", name_en: "Central"),
    Province.new(code: "ZM-08", iso3166: "ZM-08", name_en: "Copperbelt"),
    Province.new(code: "ZM-03", iso3166: "ZM-03", name_en: "Eastern"),
    Province.new(code: "ZM-04", iso3166: "ZM-04", name_en: "Luapula"),
    Province.new(code: "ZM-09", iso3166: "ZM-09", name_en: "Lusaka"),
    Province.new(code: "ZM-10", iso3166: "ZM-10", name_en: "Muchinga"),
    Province.new(code: "ZM-06", iso3166: "ZM-06", name_en: "North-Western"),
    Province.new(code: "ZM-05", iso3166: "ZM-05", name_en: "Northern"),
    Province.new(code: "ZM-07", iso3166: "ZM-07", name_en: "Southern"),
    Province.new(code: "ZM-01", iso3166: "ZM-01", name_en: "Western")
  ]
end

namespace :data_migrations do
  task migrate_contact_metadata_to_native_fields: :environment do
    Account.find_each do |account|
      puts "Migrating contacts for account: #{account.id}"

      contacts = account.contacts.where(iso_country_code: nil)
      contacts.find_each do |contact|
        ApplicationRecord.transaction do
          contact.iso_country_code = PhonyRails.country_from_number(contact.msisdn)
          contact.language_code = contact.metadata["language_code"]
          contact.save!

          # EWS Cambodia
          contact.metadata.fetch("commune_ids", []).each do | commune_id |
            commune = Pumi::Commune.find_by_id(phone_call_metadata(:commune_code))
            next if commune.blank?

            contact.addresses.find_or_create_by!(
              iso_region_code: commune.province.iso3166_2,
              administrative_division_level_2_code: commune.district_id,
              administrative_division_level_3_code: commune.id
            )
          end

          # EWS Laos
          contact.metadata.fetch("registered_districts", []).each do | district_code |
            district = CallFlowLogic::EWSLaosRegistration::DISTRICTS.find { |d| d.code ==  district_code }
            next if district.blank?

            contact.addresses.find_or_create_by!(
              iso_region_code: district.province.iso3166,
              administrative_division_level_2_code: district.code,
            )
          end

          # PIN Zambia
          if account.id == 110
            province = ZAMBIA_PROVINCES.find { |d| d.name_en ==  contact.metadata["province"] }
            next if province.blank?

            contact.addresses.find_or_create_by!(
              iso_region_code: province.iso3166,
              administrative_division_level_2_name: contact.metadata["district"],
              administrative_division_level_3_name: contact.metadata["facility"]
            )
          end

          # Africa's Voices (Somalia)
          # metadata: {"group"=>"Wajid_2", "location"=>"Wajid Town", "householdname"=>"BAKWAJ0010233"}
          # metadata: {"dec10"=>"True", "district"=>"Wajid", "location"=>"Wajid", "retailer"=>"World Vision Topup Kabasa IDP", "scope_id"=>"BAKWAJ0001996"}
        end
      end
    end
  end
end
