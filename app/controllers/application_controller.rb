class ApplicationController < ActionController::Base
  before_action :load_projects

  def load_projects
    @projects = Project.all
  end
  protect_from_forgery with: :exception
end
