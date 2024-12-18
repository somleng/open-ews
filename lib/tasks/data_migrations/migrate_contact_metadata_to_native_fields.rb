namespace :data_migrations do
  task migrate_contact_metadata_to_native_fields: :environment do
    Account.find_each do |account|
      puts "Migrating contacts for account: #{account.id}"

      account.contacts.find_each do |contact|
        ApplicationRecord.transaction do
          contact.iso_country_code = PhonyRails.country_from_number(contact.msisdn)
          contact.language_code = contact.metadata["language_code"]
          contact.save!

          # EWS Cambodia
          contact.metadata.fetch("commune_ids", []).each do | commune_id |
            commune = Pumi::Commune.find_by_id(phone_call_metadata(:commune_code))

            contact.addresses.find_or_create_by!(
              iso_region_code: commune.province.iso3166_2,
              administrative_division_level_2_code: commune.district_id,
              administrative_division_level_3_code: commune.id
            )
          end

          # EWS Laos
          contact.metadata.fetch("registered_districts", []).each do | district_code |
            district = CallFlowLogic::EWSLaosRegistration::DISTRICTS.find { |d| d.code ==  district_code }

            contact.addresses.find_or_create_by!(
              iso_region_code: district.province.iso3166,
              administrative_division_level_2_code: district.code,
            )
          end

          # Africa's Voices (Somalia)
          # metadata: {"name"=>"John Doe", "district"=>"Kalabo", "language"=>"Lozi", "province"=>"Western"}

          # PIN Zambia
          # metadata: {"name"=>"John Doe", "address"=>"Newa", "district"=>"Nalolo", "facility"=>"Mouyo", "language"=>"silozi", "province"=>"Western", "date_of_registration"=>"29/10/2021"}
        end
      end
    end
  end
end
