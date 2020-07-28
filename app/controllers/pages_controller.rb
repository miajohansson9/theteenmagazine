class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:issue, :privacy, :subscribe, :sitemap, :contact, :team, :submitted, :reset, :reset_confirmation]
  layout "minimal", except: [:issue, :about, :team, :privacy, :reset, :contact, :subscribe]

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
    set_meta_tags :title => "Choosing a Topic | The Teen Magazine"
  end

  def writing
    set_meta_tags :title => "Writing the Perfect Article | The Teen Magazine"
  end

  def reviews(post)
    @post = post
  end

  def images
    set_meta_tags :title => "Finding Images | The Teen Magazine"
  end

  def privacy
  end

  def sitemap
    redirect_to 'https://s3.amazonaws.com/media.theteenmagazine.com/sitemaps/sitemap.xml.gz'
  end

  def about
  end

  def submitted
  end

  def subscribe
    set_meta_tags :title => "The Teen Magazine | 2020 July Issue",
                  :description => "Subscribe to download our July issue.",
                  :image => "https://www.theteenmagazine.com/assets/ttm-july-2020-20fbf4ec4a74c308ba3788f2adf7281afa4a87fa15b05c91c10466f1e1b9657e.png",
                  :fb => {
                    :app_id => "1190455601051741"
                  },
                  :og => {
                    :image => {
                      :url => "https://www.theteenmagazine.com/assets/ttm-july-2020-20fbf4ec4a74c308ba3788f2adf7281afa4a87fa15b05c91c10466f1e1b9657e.png",
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
                    description: "Subscribe to download our July issue.",
                    :image => "https://www.theteenmagazine.com/assets/ttm-july-2020-20fbf4ec4a74c308ba3788f2adf7281afa4a87fa15b05c91c10466f1e1b9657e.png",
                    :domain => "https://www.theteenmagazine.com/"
                  }
  end

  def issue
    if params[:pages].present?
      if params[:pages][:sub].eql? "1"
        begin
          @gb = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
          @gb.lists(ENV['MAILCHIMP_LIST_ID']).members.create(body: {email_address: params[:pages][:email], status: "subscribed"})
        rescue
          puts "Error: Failed to subscribe to mailchimp list"
        end
      end
    end
  end

  def reset
    @user = User.new
  end
end
