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

      id = instance.id
      id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
      url = "https://s3.amazonaws.com/media.theteenmagazine.com/#{instance.class.table_name}/#{attachment.pluralize}/#{id_partition}/original/#{filename}"
      puts url

      begin
        instance.send(attachment.to_sym).attach(
            io: open(url),
            filename: instance.send(name_field),
            content_type: instance.send(:"#{attachment}_content_type")
        )
      rescue
        puts 'failed to upload instance'
      end
    end
  end

  task migrate_pitches: :environment do
    puts "starting to migrate pitches"
    klass = Pitch
    attachment = 'thumbnail'
    name_field = :"#{attachment}_file_name"

    klass.where.not(name_field => nil).find_each do |instance|
      # This step helps us catch any attachments we might have uploaded that
      # don't have an explicit file extension in the filename

      filename = instance.send("#{attachment}_file_name")

      next if filename.blank?

      id = instance.id
      id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
      url = "https://s3.amazonaws.com/media.theteenmagazine.com/#{instance.class.table_name}/#{attachment.pluralize}/#{id_partition}/original/#{filename}"
      puts url

      begin
        instance.send(attachment.to_sym).attach(
            io: open(url),
            filename: instance.send(name_field),
            content_type: instance.send(:"#{attachment}_content_type")
        )
      rescue
        puts 'failed to upload instance'
      end
    end
  end

  task migrate_posts: :environment do
    puts "starting to migrate posts"
    klass = Post
    attachment = 'thumbnail'
    name_field = :"#{attachment}_file_name"

    klass.where.not(name_field => nil).find_each do |instance|
      # This step helps us catch any attachments we might have uploaded that
      # don't have an explicit file extension in the filename

      filename = instance.send("#{attachment}_file_name")

      next if filename.blank?

      id = instance.id
      id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
      url = "https://s3.amazonaws.com/media.theteenmagazine.com/#{instance.class.table_name}/#{attachment.pluralize}/#{id_partition}/original/#{filename}"
      puts url

      begin
        instance.send(attachment.to_sym).attach(
            io: open(url),
            filename: instance.send(name_field),
            content_type: instance.send(:"#{attachment}_content_type")
        )
      rescue
        puts 'failed to upload instance'
      end
    end
  end

  task migrate_categories: :environment do
    puts "starting to migrate categories"
    klass = Category
    attachment = 'image'
    name_field = :"#{attachment}_file_name"

    klass.where.not(name_field => nil).find_each do |instance|
      # This step helps us catch any attachments we might have uploaded that
      # don't have an explicit file extension in the filename

      filename = instance.send("#{attachment}_file_name")

      next if filename.blank?

      id = instance.id
      id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
      url = "https://s3.amazonaws.com/media.theteenmagazine.com/#{instance.class.table_name}/#{attachment.pluralize}/#{id_partition}/original/#{filename}"
      puts url

      begin
        instance.send(attachment.to_sym).attach(
            io: open(url),
            filename: instance.send(name_field),
            content_type: instance.send(:"#{attachment}_content_type")
        )
      rescue
        puts 'failed to upload instance'
      end
    end
  end

  task migrate_newsletters: :environment do
    puts "starting to migrate newsletters"
    klass = Newsletter
    attachment = 'hero_image'
    name_field = :"#{attachment}_file_name"

    klass.where.not(name_field => nil).find_each do |instance|
      # This step helps us catch any attachments we might have uploaded that
      # don't have an explicit file extension in the filename

      filename = instance.send("#{attachment}_file_name")

      next if filename.blank?

      id = instance.id
      id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
      url = "https://s3.amazonaws.com/media.theteenmagazine.com/#{instance.class.table_name}/#{attachment.pluralize}/#{id_partition}/original/#{filename}"
      puts url

      begin
        instance.send(attachment.to_sym).attach(
            io: open(url),
            filename: instance.send(name_field),
            content_type: instance.send(:"#{attachment}_content_type")
        )
      rescue
        puts 'failed to upload instance'
      end
    end
  end

  task migrate_applies: :environment do
    puts "starting to migrate applies resume"
    klass = Apply
    attachment = 'resume'
    name_field = :"#{attachment}_file_name"

    klass.where.not(name_field => nil).find_each do |instance|
      # This step helps us catch any attachments we might have uploaded that
      # don't have an explicit file extension in the filename

      filename = instance.send("#{attachment}_file_name")

      next if filename.blank?

      id = instance.id
      id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
      url = "https://s3.amazonaws.com/media.theteenmagazine.com/#{instance.class.table_name}/#{attachment.pluralize}/#{id_partition}/original/#{filename}"
      puts url

      begin
        instance.send(attachment.to_sym).attach(
            io: open(url),
            filename: instance.send(name_field),
            content_type: instance.send(:"#{attachment}_content_type")
        )
      rescue
        puts 'failed to upload instance'
      end
    end
  end

  task migrate_applies: :environment do
    puts "starting to migrate applies sample_writing"
    klass = Apply
    attachment = 'sample_writing'
    name_field = :"#{attachment}_file_name"

    klass.where.not(name_field => nil).find_each do |instance|
      # This step helps us catch any attachments we might have uploaded that
      # don't have an explicit file extension in the filename

      filename = instance.send("#{attachment}_file_name")

      next if filename.blank?

      id = instance.id
      id_partition = ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
      url = "https://s3.amazonaws.com/media.theteenmagazine.com/#{instance.class.table_name}/#{attachment.pluralize}/#{id_partition}/original/#{filename}"
      puts url

      begin
        instance.send(attachment.to_sym).attach(
            io: open(url),
            filename: instance.send(name_field),
            content_type: instance.send(:"#{attachment}_content_type")
        )
      rescue
        puts 'failed to upload instance'
      end
    end
  end
end