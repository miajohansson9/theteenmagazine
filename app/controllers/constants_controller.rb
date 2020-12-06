class ConstantsController < ApplicationController
  before_action :find_constant, except: [:new, :create, :index]
  before_action :is_admin?
  before_action :authenticate_user!
  load_and_authorize_resource
  layout "minimal"

  def new
    @constant = Constant.new
    set_meta_tags :title => "New Constant Field"
  end

  def edit
    set_meta_tags :title => "Edit Constant Field"
  end

  def index
    @constants = Constant.all
    set_meta_tags :title => "Constant Fields"
  end

  def update
    if @constant.update constant_params
      @constant.save
      redirect_to constants_path, notice: "Your changes were updated."
    else
      render 'edit', notice: "Oops, something went wrong."
    end
  end

  def create
    if @constant.save
      redirect_to constants_path, notice: "Your constant was successfully added!"
    else
      render 'new', notice: "Oh no! Your changes were not able to be saved!"
    end
  end

  def is_admin?
    redirect_to root_path, notice: "You do not have access to this page." unless (current_user && current_user.admin?)
  end

  def destroy
    @constant.destroy
    redirect_to constants_path, notice: "Constant deleted."
  end

  private

  def constant_params
    params.require(:constant).permit(:id, :name, :value, :slug)
  end

  def find_constant
    @constant = Constant.find(params[:id])
  end
end
