class AppliesController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :is_admin?, only: [:show, :index]

  #show all applications
  def index
    @applies = Apply.all.paginate(page: params[:page]).order("created_at desc")
  end

  #create a new application
  def new
    @application = Apply.new
    set_meta_tags title: "Apply",
                  description: "Our writer team is made up of hundreds of college and high school writers from around the world who are passionate about improving their writing skills and are excited to connect with other like-minded writers. Apply to our team!"
  end

  #send submitted application
  def create
    @application = Apply.new(apply_params)
    @application.request = request
    if @application.deliver
      flash.now[:error] = nil
    else
      flash.now[:error] = 'Cannot send message'
      render :new
    end
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
