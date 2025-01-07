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

ACCOUNT_COUNTRY_CODES = {
  2 => "SO",
  3 => "KH",
  4 => "KH",
  7 => "SL",
  8 => "TH",
  11 => "US",
  45 => "MX",
  77 => "EG",
  110 => "ZM",
  143 => "KH",
  209 => "LA"
}

cache = {}

namespace :data_migrations do
  task migrate_contact_metadata_to_native_fields: :environment do
    Account.find_each do |account|
      puts "Migrating contacts for account: #{account.id}"

      contacts = account.contacts.where(iso_country_code: nil)
      contacts.find_each do |contact|
        ApplicationRecord.transaction do
          contact.update_columns(
            iso_country_code: ACCOUNT_COUNTRY_CODES.fetch(account.id),
            language_code: contact.metadata["language_code"]
          )

          # EWS Cambodia
          Array(contact.metadata["commune_ids"]).each do | commune_id |
            cache[commune_id] ||= Pumi::Commune.find_by_id(commune_id)
            commune = cache[commune_id]
            next if commune.blank?

            contact.addresses.find_or_create_by!(
              iso_country_code: "KH",
              iso_region_code: commune.province.iso3166_2,
              administrative_division_level_2_code: commune.district_id,
              administrative_division_level_2_name: commune.district.name_en,
              administrative_division_level_3_code: commune.id,
              administrative_division_level_3_name: commune.name_en,
              created_at: contact.updated_at,
              updated_at: contact.updated_at
            )
          end

          # EWS Laos
          Array(contact.metadata["registered_districts"]).each do | district_code |
            district = CallFlowLogic::EWSLaosRegistration::DISTRICTS.find { |d| d.code ==  district_code }
            next if district.blank?

            contact.addresses.find_or_create_by!(
              iso_country_code: "LA",
              iso_region_code: district.province.iso3166,
              administrative_division_level_2_code: district.code,
              administrative_division_level_2_name: district.name_en,
              created_at: contact.updated_at,
              updated_at: contact.updated_at
            )
          end

          # PIN Zambia
          if account.id == 110
            province = Subdivisions::ZAMBIA_PROVINCES.find { |d| d.name_en ==  contact.metadata["province"] }
            next if province.blank?

            contact.addresses.find_or_create_by!(
              iso_country_code: "ZM",
              iso_region_code: province.iso3166,
              administrative_division_level_2_name: contact.metadata["district"],
              administrative_division_level_3_name: contact.metadata["facility"]
            )
          end
        end
      end
    end
  end
end
