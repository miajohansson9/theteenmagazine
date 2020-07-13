class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:privacy, :subscribe, :sitemap, :contact, :team, :submitted, :reset, :reset_confirmation]
  layout "minimal", except: [:about, :team, :privacy, :reset, :contact, :subscribe]

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
    redirect_to 'https://theteenmagazine.s3.amazonaws.com/sitemaps/sitemap.xml.gz'
  end

  def about
  end

  def submitted
  end

  def subscribe
  end

  def issue
  end

  def reset
    @user = User.new
  end
end
