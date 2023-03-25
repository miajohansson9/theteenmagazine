class PagesController < ApplicationController
  before_action :authenticate_user!,
                except: %i[
                  trending
                  ads
                  issue
                  privacy
                  subscribe
                  email_preferences
                  update_email_preferences
                  sitemap
                  contact
                  team
                  submitted
                  reset
                  reset_confirmation
                  search
                ]
  before_action :is_admin?, only: :most_viewed

  def team
    set_meta_tags title: "About us",
                  description: "We believe that teen magazines should be inclusive and focus on topics written by, and important to, teens."
  end

  def contact
    set_meta_tags title: "Contact us | The Teen Magazine"
  end

  def criteria
    set_meta_tags title: "Criteria & FAQ | The Teen Magazine"
  end

  def topics
    @pitch = Pitch.new
    @categories = Category.active
    set_meta_tags title: "Pitching an Article | The Teen Magazine"
    current_user.update(read_pitches: true)
  end

  def writing
    set_meta_tags title: "Writing the Perfect Article | The Teen Magazine"
    current_user.update(read_articles: true)
  end

  def reviews(post)
    @post = post
  end

  def images
    set_meta_tags title: "Finding Images | The Teen Magazine"
    current_user.update(read_images: true)
  end

  def privacy; end

  def sitemap
    redirect_to "https://s3.amazonaws.com/media.theteenmagazine.com/sitemaps/sitemap.xml.gz"
  end

  def about; end

  def trending
    @pagy, @trending =
      pagy(Post.published.trending, page: params[:page], items: 15)
    set_meta_tags title: "Trending | The Teen Magazine",
                  image: @trending.first.thumbnail.variant(resize_to_fill: [540, 340]),
                  description: "See what's trending on The Teen Magazine",
                  fb: {
                    app_id: "1190455601051741",
                  },
                  og: {
                    image: {
                      url: @trending.first.thumbnail.variant(resize_to_fill: [540, 340]),
                      alt: "The Teen Magazine",
                    },
                    site_name: "The Teen Magazine",
                  },
                  article: {
                    publisher: "https://www.facebook.com/theteenmagazinee",
                  },
                  twitter: {
                    card: "summary_large_image",
                    site: "@theteenmagazin_",
                    title: "The Teen Magazine",
                    description: "See what's trending on The Teen Magazine",
                    image: @trending.first.thumbnail.variant(resize_to_fill: [540, 340]),
                    domain: "https://www.theteenmagazine.com/",
                  }
  end

  def most_viewed
    @pagy, @most_viewed =
      pagy(Post.published.most_viewed, page: params[:page], items: 15)
    set_meta_tags title: "Most Viewed | The Teen Magazine"
  end

  def submitted; end

  def reviewing_pitches
    set_meta_tags title: "Pitch Requirements | The Teen Magazine"
  end

  def reviewing_articles
    set_meta_tags title: "Article Requirements | The Teen Magazine"
  end

  def pitching_new_articles
    set_meta_tags title: "Pitching New Articles | The Teen Magazine"
    @categories = Category.active
  end

  def start
    @reviews_requirement =
      Constant
        .find_by(name: "# of monthly reviews editors need to complete")
        .try(:value)
    @pitches_requirement =
      Constant
        .find_by(name: "# of monthly pitches editors need to complete")
        .try(:value)
    @max_reviews =
      Constant
        .find_by(name: "max # of reviews per month for editors")
        .try(:value)
    set_meta_tags title: "Editor Onboarding | The Teen Magazine"
  end

  def search
    if params[:search].present?
      @query = params[:search][:query]
      @filter = params[:search][:filter]
      if @filter.eql? "writers"
        @pagy, @users =
          pagy(
            User
              .where(partner: [false, nil])
              .is_published
              .where("lower(full_name) LIKE ?", "%#{@query.downcase}%")
              .order("full_name asc"),
            page: params[:page],
            items: 15,
          )
      else
        @pagy, @posts =
          pagy(
            Post
              .published
              .where("lower(title) LIKE ?", "%#{@query.downcase}%")
              .by_published_date,
            page: params[:page],
            items: 15,
          )
      end
    else
      if params[:filter].present?
        @filter = params[:filter]
        if @filter.eql? "writers"
          @pagy, @users =
            pagy(
              User
                .where(partner: [false, nil])
                .is_published
                .order("full_name asc"),
              page: params[:page],
              items: 15,
            )
        else
          @pagy, @posts =
            pagy(
              Post.published.by_published_date,
              page: params[:page],
              items: 15,
            )
        end
      else
        @filter = "all articles"
        @pagy, @posts =
          pagy(Post.published.by_published_date, page: params[:page], items: 15)
      end
    end
    @next = (@filter.eql? "writers") ? "all articles" : "writers"
    set_meta_tags title: "Search | The Teen Magazine"
  end

  def subscribe
    set_meta_tags title: "The Teen Magazine | 2021 September Issue",
                  description: "Subscribe to download our September Issue.",
                  image: "https://s3.amazonaws.com/media.theteenmagazine.com/September+2021.png",
                  fb: {
                    app_id: "1190455601051741",
                  },
                  og: {
                    image: {
                      url: "https://s3.amazonaws.com/media.theteenmagazine.com/September+2021.png",
                      alt: "The Teen Magazine",
                    },
                    site_name: "The Teen Magazine",
                  },
                  article: {
                    publisher: "https://www.facebook.com/theteenmagazinee",
                  },
                  twitter: {
                    card: "summary_large_image",
                    site: "@theteenmagazin_",
                    title: "The Teen Magazine",
                    description: "Subscribe to download our September Issue.",
                    image: "https://s3.amazonaws.com/media.theteenmagazine.com/September+2021.png",
                    domain: "https://www.theteenmagazine.com/",
                  }
  end

  def email_preferences
    @gb = Gibbon::Request.new(api_key: ENV["MAILCHIMP_API_KEY"])
    if params[:pages].present?
      @user = User.find_by(email: params[:pages][:email])
    else
      @user = current_user
    end
    update_email_preferences
    # begin
    #   @subscribed_to_readers =
    #     @gb
    #       .lists(ENV["MAILCHIMP_LIST_ID"])
    #       .members(params[:email])
    #       .retrieve(params: { 'fields': "status" })
    #       .body[
    #       "status"
    #     ].eql? "subscribed"
    # rescue StandardError
    #   @subscribed_to_readers = false
    # end
    # @user = User.find_by(email: params[:email])
    # begin
    #   @subscribed_to_writers =
    #     @gb
    #       .lists(ENV["MAILCHIMP_WRITER_LIST_ID"])
    #       .members(params[:email])
    #       .retrieve(params: { 'fields': "status" })
    #       .body[
    #       "status"
    #     ].eql? "subscribed" || !@user.try(:do_not_send_emails)
    # rescue StandardError
    #   @subscribed_to_writers = false
    # end
    @subscribed_to_newsletter = @user.remove_from_reader_newsletter.nil? || !@user.remove_from_reader_newsletter
    @subscribed_to_writer_newsletter = @user.remove_from_writer_newsletter.nil? || !@user.remove_from_writer_newsletter
    @subscribed_to_writer_updates = @user.do_not_send_emails.nil? || !@user.do_not_send_emails
  end

  def update_email_preferences
    @gb = Gibbon::Request.new(api_key: ENV["MAILCHIMP_API_KEY"])
    if params[:pages].present?
      @user = User.find_by(email: params[:pages][:email])
      if params[:pages][:newsletter].eql? "1"
        # wants to be subscribed to reader newsletter
        begin
          @gb
            .lists(ENV["MAILCHIMP_LIST_ID"])
            .members(params[:pages][:email])
            .update(body: { status: "subscribed" })
        rescue StandardError
          @gb
            .lists(ENV["MAILCHIMP_LIST_ID"])
            .members
            .create(
              body: {
                email_address: params[:pages][:email],
                status: "subscribed",
              },
            )
        end
        @user.update_column("remove_from_reader_newsletter", false)
      else
        # does not want to be subscribed to reader newsletter
        begin
          @gb
            .lists(ENV["MAILCHIMP_LIST_ID"])
            .members(params[:pages][:email])
            .update(body: { status: "unsubscribed" })
        rescue StandardError
          @errors = true
        end
        @user.update_column("remove_from_reader_newsletter", true)
      end
      if @user != nil && (@user.id.to_s.eql? params[:pages][:id])
        if params[:pages][:writer_newsletter].eql? "1"
          # does want to be subscribed to writer newsletter
          begin
            @gb
              .lists(ENV["MAILCHIMP_WRITER_LIST_ID"])
              .members(params[:pages][:email])
              .update(body: { status: "subscribed" })
          rescue StandardError
            @gb
              .lists(ENV["MAILCHIMP_WRITER_LIST_ID"])
              .members
              .create(
                body: {
                  email_address: params[:pages][:email],
                  status: "subscribed",
                },
              )
          end
          @user.update_column("remove_from_writer_newsletter", false)
        else
          # does not want to be subscribed to writer newsletter
          begin
            @gb
              .lists(ENV["MAILCHIMP_WRITER_LIST_ID"])
              .members(params[:pages][:email])
              .update(body: { status: "unsubscribed" })
          rescue StandardError
            @errors = true
          end
          @user.update_column("remove_from_writer_newsletter", true)
        end
      else
        @errors = true
      end
      if @user != nil && (@user.id.to_s.eql? params[:pages][:id])
        if params[:pages][:writer].eql? "1"
          # does want to get writer updates about their account
          @user.update_column("do_not_send_emails", false)
        else
          # does not want to get writer updates about their account
          @user.update_column("do_not_send_emails", true)
        end
      end

      if @errors
        flash.now[:notice] = "There was an error saving your preferences"
      else
        flash.now[:notice] =
          "Updated #{params[:pages][:email]} email preferences successfully"
      end
    end
  end

  def issue
    if params[:pages].present?
      if params[:pages][:sub].eql? "1"
        begin
          if isEmail(params[:pages][:email])
            @gb = Gibbon::Request.new(api_key: ENV["MAILCHIMP_API_KEY"])
            @gb
              .lists(ENV["MAILCHIMP_LIST_ID"])
              .members
              .create(
                body: {
                  email_address: params[:pages][:email],
                  status: "subscribed",
                },
              )
            flash.now[:notice] =
              "You're subscribed to The Teen Magazine's newsletter!"
          else
            redirect_to "/subscribe",
                        notice: "Please enter a valid email address."
          end
        rescue StandardError
          puts "Error: Failed to subscribe to mailchimp list"
        end
      end
    end
  end

  def isEmail(str)
    return str.match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def reset
    @user = User.new
  end

  def is_admin?
    if (current_user && (current_user.admin? || current_user.editor?))
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end
end
