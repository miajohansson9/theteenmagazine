require "open-uri"

namespace :testdata do
  task users: :environment do
    10.times do |i|
      count = i + User.last.id
      @user = User.new(
        first_name: "Test User",
        last_name: "#{count}",
        full_name: "Test User #{count}",
        email: "testuser#{count}@theteenmagazine.com",
        password: "123456",
      )
      @user.save!
      puts "Created test user"
    end
  end

  task subscribers: :environment do
    User.editor.each do |user|
      @token = SecureRandom.urlsafe_base64
      @subscriber = Subscriber.new(
        email: user.email,
        user_id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        token: @token,
        source: "Test data",
        opted_in_at: Time.now,
        subscribed_to_reader_newsletter: true,
        subscribed_to_writer_newsletter: true,
      )
      @subscriber.save!
      puts "Added editor to subscriber list"
    end
  end

  task pitches: :environment do
    10.times do |i|
      @pitch = Pitch.new(
        title: "Test pitch generated from script #{i}",
        deadline: 2,
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        editor_id: User.editor.first.id,
        user_id: User.editor.first.id,
        agree_to_image_policy: true,
        category_id: 7,
        claimed_id: nil,
      )
      downloaded_image = open("app/assets/images/thumbnail_placeholder.png")
      @pitch.thumbnail.attach(io: downloaded_image, filename: "thumbnail_placeholder.png", content_type: "image/png")
      @pitch.save!
      puts "Created test pitch"
    end
  end

  task pitches_high: :environment do
    10.times do |i|
      @pitch = Pitch.new(
        title: "Test pitch generated from script #{i}",
        priority: "High",
        deadline: 2,
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        editor_id: User.editor.first.id,
        user_id: User.editor.first.id,
        agree_to_image_policy: true,
        category_id: 2,
        claimed_id: nil,
      )
      downloaded_image = open("app/assets/images/thumbnail_placeholder.png")
      @pitch.thumbnail.attach(io: downloaded_image, filename: "thumbnail_placeholder.png", content_type: "image/png")
      @pitch.save!
      puts "Created test pitch"
    end
  end

  task constants: :environment do
    @max_reviews = Constant.new(name: "# of monthly reviews editors need to complete", value: 2)
    @max_reviews.save!

    @pitches_requirement = Constant.new(name: "# of monthly pitches editors need to complete", value: 2)
    @pitches_requirement.save!

    @max_reviews = Constant.new(name: "max # of reviews per month for editors", value: 20)
    @max_reviews.save!

    @comments_requirement = Constant.new(name: "# of monthly comments editors need to complete", value: 5)
    @comments_requirement.save!

    puts "Set constants"
  end
end
