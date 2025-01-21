namespace :data_migrate do
  task migrate_phone_number: :environment do
    batch_size = 1000

    phone_calls = PhoneCall.where("msisdn LIKE '+%'")
    phone_calls_count = phone_calls.count
    puts "Total phone calls: #{phone_calls_count} (batches: #{phone_calls_count / batch_size})"

    phone_calls.in_batches(of: batch_size) do |relation, batch_index|
      puts "Processing phone calls: ##{batch_index}"

      relation.update_all("msisdn = REPLACE(msisdn, '+', '')")
    end


    puts "Total Callout Participations : #{CalloutParticipation.count}"
    ApplicationRecord.connection.execute <<-SQL
      UPDATE callout_participations cp
      SET beneficiary_phone_number = c.msisdn
      FROM contacts c
      WHERE cp.contact_id = c.id
    SQL
  end
end
