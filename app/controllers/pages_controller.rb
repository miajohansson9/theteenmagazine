class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:privacy, :contact, :team, :submitted, :reset, :reset_confirmation]
  layout "minimal", except: [:about, :team, :privacy, :reset, :contact]

  def team
    set_meta_tags :title => "About us",
                  :description => "We believe that teen magazines should be inclusive and focus on topics written by, and important to, teens."
  end

  def contact
    set_meta_tags :title => "Contact us | The Teen Magazine"
  end

  def criteria
  end

  def topics
    @pitch = Pitch.new
    @categories = Category.all
  end

  def writing
    @post = current_user.posts.build
  end

  def reviews(post)
    @post = post
  end

  def images
  end

  def privacy
  end

  def about
  end

  def submitted
  end

  def reset
    @user = User.new
  end
end
