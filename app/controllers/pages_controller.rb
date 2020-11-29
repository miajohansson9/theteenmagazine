class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:ads, :issue, :privacy, :subscribe, :sitemap, :contact, :team, :submitted, :reset, :reset_confirmation, :search]
  before_action :is_admin?, only: :featured
  layout "minimal", except: [:issue, :about, :team, :privacy, :reset, :contact, :subscribe, :search]

  def team
    set_meta_tags :title => "About us",
                  :description => "We believe that teen magazines should be inclusive and focus on topics written by, and important to, teens."
  end

  def contact
    set_meta_tags :title => "Contact us | The Teen Magazine"
  end

  def criteria
    set_meta_tags :title => "Criteria & FAQ | The Teen Magazine"
  end

  def topics
    @pitch = Pitch.new
    @categories = Category.all
    set_meta_tags :title => "Pitching an Article | The Teen Magazine"
    current_user.update(read_pitches: true)
  end

  def writing
    set_meta_tags :title => "Writing the Perfect Article | The Teen Magazine"
    current_user.update(read_articles: true)
  end

  def reviews(post)
    @post = post
  end

  def images
    set_meta_tags :title => "Finding Images | The Teen Magazine"
    current_user.update(read_images: true)
  end

  def privacy
  end

  def ads
    redirect_to 'https://srv.adstxtmanager.com/10188/theteenmagazine.com'
  end

  def sitemap
    redirect_to 'https://s3.amazonaws.com/media.theteenmagazine.com/sitemaps/sitemap.xml.gz'
  end

  def about
  end

  def newsletter
    @posts = Post.published.where(newsletter: true)
  end

  def submitted
  end

  def reviewing_pitches
    set_meta_tags :title => "Pitch Requirements | The Teen Magazine"
  end

  def reviewing_articles
    set_meta_tags :title => "Article Requirements | The Teen Magazine"
  end

  def pitching_new_articles
    set_meta_tags :title => "Pitching New Articles | The Teen Magazine"
    @categories = Category.all
  end

  def start
    set_meta_tags :title => "Editor Onboarding | The Teen Magazine"
  end

  def search
    if params[:search].present?
      @query = params[:search][:query]
      @filter = params[:search][:filter]
      if @filter.eql? "writers"
        @pagy, @users = pagy(User.where(partner: [false, nil]).is_published.where("lower(full_name) LIKE ?", "%#{@query.downcase}%").order("full_name asc"), page: params[:page], items: 15)
      else
        @pagy, @posts = pagy(Post.published.where("lower(title) LIKE ?", "%#{@query.downcase}%").order("publish_at desc"), page: params[:page], items: 15)
      end
    else
      if params[:filter].present?
        @filter = params[:filter]
        if @filter.eql? "writers"
          @pagy, @users = pagy(User.where(partner: [false, nil]).is_published.order("full_name asc"), page: params[:page], items: 15)
        else
          @pagy, @posts = pagy(Post.published.order("publish_at desc"), page: params[:page], items: 15)
        end
      else
        @filter = "all articles"
        @pagy, @posts = pagy(Post.published.order("publish_at desc"), page: params[:page], items: 15)
      end
    end
    @next = (@filter.eql? "writers") ? "all articles" : "writers"
    set_meta_tags :title => "Search | The Teen Magazine"
  end

  def subscribe
    set_meta_tags :title => "The Teen Magazine | 2020 October Issue",
                  :description => "Subscribe to download our October issue.",
                  :image => "https://s3.amazonaws.com/media.theteenmagazine.com/october_issue_cover.png",
                  :fb => {
                    :app_id => "1190455601051741"
                  },
                  :og => {
                    :image => {
                      :url => "https://s3.amazonaws.com/media.theteenmagazine.com/october_issue_cover.png",
                      :alt => 'The Teen Magazine',
                    },
                    :site_name => "The Teen Magazine",
                  },
                  :article => {
                    :publisher => "https://www.facebook.com/theteenmagazinee"
                  },
                  :twitter => {
                    :card => "summary_large_image",
                    :site => "@theteenmagazin_",
                    :title => "The Teen Magazine",
                    description: "Subscribe to download our October issue.",
                    :image => "https://s3.amazonaws.com/media.theteenmagazine.com/october_issue_cover.png",
                    :domain => "https://www.theteenmagazine.com/"
                  }
  end

  def issue
    if params[:pages].present?
      if params[:pages][:sub].eql? "1"
        begin
          @gb = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
          @gb.lists(ENV['MAILCHIMP_LIST_ID']).members.create(body: {email_address: params[:pages][:email], status: "subscribed"})
          flash.now[:notice] = "Subscribed to newsletter."
        rescue
          puts "Error: Failed to subscribe to mailchimp list"
        end
      end
    end
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
