require 'csv'

namespace :subscribers do
    task migrate_users: :environment do
        subscribers = []
        User.writer.all.each do |user|
            @token = SecureRandom.urlsafe_base64
            @subscribed_to_reader_newsletter = user.remove_from_reader_newsletter.nil? || (user.remove_from_reader_newsletter.eql? false)
            @subscribed_to_writer_newsletter = user.remove_from_writer_newsletter.nil? || (user.remove_from_writer_newsletter.eql? false)
            subscriber = {
                email: user.email, 
                first_name: user.first_name, 
                last_name: user.last_name, 
                user_id: user.id,
                token: @token,
                source: "Became a writer",
                opted_in_at: user.created_at,
                subscribed_to_reader_newsletter: @subscribed_to_reader_newsletter,
                subscribed_to_writer_newsletter: @subscribed_to_writer_newsletter,
            }
            if subscribers.push(subscriber)
                puts "Added subscriber #{user.email}"
            else
                puts "Error adding subscriber #{user.email}"
            end
        end
        if Subscriber.insert_all(subscribers)
            puts "Inserted #{subscribers.count} subscribers"
        else
            puts "Error inserting #{subscribers.count} subscribers"
        end
    end

    task migrate_readers: :environment do
        subscribers = []
        CSV.foreach('subscribed_members_export_a88ed6a6bf.csv', :headers => true) do |row|
            if !Subscriber.find_by('lower(email) = ?', row['Email Address']).present?
                @first_name = row['First Name']
                @last_name = row['Last Name']
                @token = SecureRandom.urlsafe_base64
                if row['First Name'].present? && row['First Name'].include?(' ')
                    @first_name = row['First Name'].split(' ')[0]
                    @last_name = row['First Name'].split(' ')[1]
                end
                @source = row['Source Location'] || "Migrated from Mailchimp"
                subscriber = {
                    email: row['Email Address'], 
                    first_name: @first_name, 
                    last_name: @last_name, 
                    token: @token,
                    source: @source,
                    opted_in_at: row['OPTIN_TIME'],
                    subscribed_to_reader_newsletter: true,
                    subscribed_to_writer_newsletter: false,
                }
                if subscribers.push(subscriber)
                    puts "Added subscriber #{row['Email Address']}"
                else
                    puts "Error adding subscriber #{row['Email Address']}"
                end
            end
        end
        if Subscriber.insert_all(subscribers)
            puts "Inserted #{subscribers.count} subscribers"
        else
            puts "Error inserting #{subscribers.count} subscribers"
        end
    end
end
        