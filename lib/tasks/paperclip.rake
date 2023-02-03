namespace :paperclip do
  task migrate_users: :environment do
    puts "starting to migrate users"
    klass = User
    attachment = 'profile'
    name_field = :"#{attachment}_file_name"

    klass.where.not(name_field => nil).find_each do |instance|
      # This step helps us catch any attachments we might have uploaded that
      # don't have an explicit file extension in the filename

      filename = instance.send("#{attachment}_file_name")

      next if filename.blank?

      url = "https://s3.amazonaws.com/media.theteenmagazine.com/variants/#{filename}"
      puts url
      
      instance.send(attachment.to_sym).attach(
        io: open(url),
        filename: instance.send(name_field),
        content_type: instance.send(:"#{attachment}_content_type")
      )
    end
  end
end