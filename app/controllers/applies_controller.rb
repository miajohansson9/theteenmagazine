class AppliesController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :is_admin?, only: [:show, :index]
  layout 'minimal', only: [:editor, :index]

  #show all applications
  def index
    @notifications = @notifications - @unseen_applications_cnt
    @unseen_applications_cnt = 0
    @applies = Apply.all.paginate(page: params[:page]).order("created_at desc")
    current_user.last_saw_writer_applications = Time.now
    current_user.save
    set_meta_tags :title => "Writer Applications | The Teen Magazine"
  end

  #create a new application
  def new
    @application = Apply.new
    set_meta_tags title: "Apply",
                  description: "Our writer team is made up of hundreds of college and high school writers from around the world who are passionate about improving their writing skills and are excited to connect with other like-minded writers. Apply to our team!",
                  image: "https://www.theteenmagazine.com/assets/become_writer-4c75511ff2d771fd380fad4dcdbeeef932870882239e52252cbea070a877761e.jpg",
                  :fb => {
                    :app_id => "1190455601051741"
                  },
                  :og => {
                    :image => {
                      :url => "https://www.theteenmagazine.com/assets/become_writer-4c75511ff2d771fd380fad4dcdbeeef932870882239e52252cbea070a877761e.jpg",
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
                    description: "Our writer team is made up of hundreds of college and high school writers from around the world who are passionate about improving their writing skills and are excited to connect with other like-minded writers. Apply to our team!",
                    :image => "https://www.theteenmagazine.com/assets/become_writer-4c75511ff2d771fd380fad4dcdbeeef932870882239e52252cbea070a877761e.jpg",
                    :domain => "https://www.theteenmagazine.com/"
                  }
  end

  #send submitted application
  def create
    @application = Apply.new(apply_params)
    set_meta_tags title: "Application Submitted"
    @application.request = request
    if @application.deliver
      flash.now[:error] = nil
    else
      flash.now[:error] = 'Cannot send message'
      render :new
    end
  end

  def editor
    set_meta_tags title: "Editor Application | The Teen Magazine",
                  description: "Our editor team is in charge of pitching new article topics, publishing/giving feedback to articles, and responding to profile submissions. We are active on Slack and support each other in helping our writer team succeed at The Teen Magazine."
  end

  #only allow admin and editors to see submitted applications
  def is_admin?
    if (current_user && (current_user.admin? || current_user.editor?))
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end

  #show application to editor
  #form for creating a new user already filled out
  def show
    @application = Apply.find(params[:id])
    # form for new user
    # when submit form, goes to registrations_controller
    @user = User.new
  end

  private

  def apply_params
    params.require(:apply).permit(:email, :first_name, :last_name, :nickname, :description)
  end
end
