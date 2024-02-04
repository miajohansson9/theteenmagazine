require "open-uri"

namespace :testdata do
  task admin_user: :environment do
    user = User.new(email: "editors@theteenmagazine.com", password: 123, first_name: "Editors", last_name: "The Teen Magazine", full_name: "Editors The Teen Magazine", admin: true, editor: true)
    user.save
  end

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

  task categories: :environment do
    beauty = Category.new(name: "Beauty and Style")
    beauty.save
    studentlife = Category.new(name: "Student Life")
    studentlife.save
    mentalHealth = Category.new(name: "Mental Health & Sell Love")
    mentalHealth.save
    opinion = Category.new(name: "Opinion")
    opinion.save
    interviews = Category.new(name: "Interviews", archive: true)
    interviews.save

    puts "Set categories"
  end

  task subscribers: :environment do
    User.editor.each do |user|
      begin
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
      rescue e
        puts e
      end
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
        category_id: Category.first.id,
        claimed_id: nil,
        thumbnail_credits: "The Teen Magazine Dev"
      )
      downloaded_image = open("app/assets/images/thumbnail_placeholder.png")
      @pitch.thumbnail.attach(io: downloaded_image, filename: "thumbnail_placeholder.png", content_type: "image/png")
      @pitch.save!
      puts "Created test pitch"
    end
  end

  task published_posts: :environment do
    10.times do |i|
      @post = Post.new(
        title: "Test pitch generated from script #{i}",
        content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        user_id: User.editor.first.id,
        agree_to_image_policy: true,
        category_id: Category.first.id,
        publish_at: Time.now,
        thumbnail_credits: "The Teen Magazine Dev"
      )
      @review = @post.reviews.build(status: "Approved for Publishing", editor_id: User.editor.first.id)
      @review.save
      downloaded_image = open("app/assets/images/thumbnail_placeholder.png")
      @post.thumbnail.attach(io: downloaded_image, filename: "thumbnail_placeholder.png", content_type: "image/png")
      @post.save!
      puts "Created published article"
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
        thumbnail_credits: "The Teen Magazine Dev"
      )
      downloaded_image = open("app/assets/images/thumbnail_placeholder.png")
      @pitch.thumbnail.attach(io: downloaded_image, filename: "thumbnail_placeholder.png", content_type: "image/png")
      @pitch.save
      puts "Created test pitch"
    end
  end

  task constants: :environment do
    @reviews_requirement =
      Constant
        .new(name: "# of monthly reviews editors need to complete", value: 3)
    @pitches_requirement =
      Constant
        .new(name: "# of monthly pitches editors need to complete", value: 2)
    @comments_requirement =
      Constant
        .new(name: "# of monthly comments editors need to complete", value: 4)
    @max_reviews =
      Constant
        .new(name: "max # of reviews per month for editors", value: 5)
    @reviews_requirement.save
    @pitches_requirement.save
    @comments_requirement.save
    @max_reviews.save
  end

  task interviews: :environment do
    following_level = ["less than 100k", "between 100k and 500k", "between 500k and 1 million", "over 1 million"]
    interview_kind = ["Actor", "Actress", "Author", "Artist", "Activist", "Content Creator", "Influencer", "Musician", "Youtuber", "Other"]
    platform_to_share = ["Instagram story w/ link (preferred)", "Instagram post description", "Youtube shoutout", "Twitter tweet", "Pinterest post", "LinkedIn post"]
    10.times do |i|
      @pitch = Pitch.new(
        title: "Notable person #{i}",
        deadline: 6,
        contact_email: "notableperson#{i}@theteenmagazine.com",
        following_level: following_level[i % following_level.length],
        user_id: nil,
        influencer_social_media: "ig: @notableperson#{i}",
        interview_kind: interview_kind[i % interview_kind.length],
        is_interview: true,
        platform_to_share: platform_to_share[i % platform_to_share.length],
        description: "Description about Notable person #{i}",
        claimed_id: nil,
      )
      @pitch.save
      puts "Created test interview request"
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
