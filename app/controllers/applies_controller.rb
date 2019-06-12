class AppliesController < ApplicationController
  before_action :is_admin?, only: [:show]

  def new
    @application = Apply.new
  end

  def create
    if params[:id]
      @user = User.new(apply_params)
      @user.save
    else
      @application = Apply.new(apply_params)
      @application.request = request
      if @application.deliver
        flash.now[:error] = nil
      else
        flash.now[:error] = 'Cannot send message'
        render :new
      end
    end
  end

  def is_admin?
    redirect_to root_path unless (current_user && (current_user.admin? || current_user.editor?))
  end

  def show
    @application = Apply.find(params[:id])
    @user = User.new
  end

  private

  def apply_params
    params.require(:apply).permit(:email, :first_name, :last_name, :nickname, :description, :category)
  end
end
