class PagesController < ApplicationController
  before_action :authenticate_user!,
                except: %i[
                  trending
                  ads
                  issue
                  privacy
                  copyright
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

  def copyright
    set_meta_tags title: "Copyright Policy | The Teen Magazine"
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
    set_meta_tags title: "Image Policy | The Teen Magazine"
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
    if params[:email].present? && params[:token].present?
      @subscriber = Subscriber.where('lower(email) = ? AND token = ?', params[:email].downcase, params[:token]).first
    elsif current_user?
      @subscriber = Subscriber.find_by(user_id: current_user.id)
    else
      return
    end
    update_email_preferences
    @subscribed_to_newsletter = !(@subscriber.subscribed_to_reader_newsletter.eql? false)
    @subscribed_to_writer_newsletter = !(@subscriber.subscribed_to_writer_newsletter.eql? false)
    @subscribed_to_writer_updates = !(@subscriber.user.do_not_send_emails.eql? true)
  end

  def update_email_preferences
    if params[:pages].present?
      @subscriber = Subscriber.where('lower(email) = ? AND token = ?', params[:pages][:email].downcase, params[:pages][:token]).first
      if params[:pages][:newsletter].eql? "1"
        # wants to be subscribed to reader newsletter
        @subscriber.update_column("subscribed_to_reader_newsletter", true)
      else
        # does not want to be subscribed to reader newsletter
        @subscriber.update_column("subscribed_to_reader_newsletter", false)
      end
      if params[:pages][:writer_newsletter].eql? "1"
        # does want to be subscribed to writer newsletter
        @subscriber.update_column("subscribed_to_writer_newsletter", true)
      else
        # does not want to be subscribed to writer newsletter
        @subscriber.update_column("subscribed_to_writer_newsletter", false)
      end
      if params[:pages][:writer].eql? "1"
        # does want to get writer updates about their account
        @subscriber.user.update_column("do_not_send_emails", false)
      else
        # does not want to get writer updates about their account
        @subscriber.user.update_column("do_not_send_emails", true)
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
    if params[:pages].present? && (params[:pages][:sub].eql? "1")
        # subscribe to email list
        @token = SecureRandom.urlsafe_base64
        subscriber = Subscriber.new(
            email: params[:pages][:email], 
            token: @token,
            source: "Subscribe page",
            opted_in_at: Time.now,
            subscribed_to_reader_newsletter: true,
            subscribed_to_writer_newsletter: false,
        )
        subscriber.save
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
