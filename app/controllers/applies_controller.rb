class AppliesController < ApplicationController
  def new
    @application = Apply.new
  end

  def create
    @application = Apply.new(params[:apply])
    @application.request = request
    if @application.deliver
      flash.now[:error] = nil
    else
      flash.now[:error] = 'Cannot send message'
      render :new
    end
  end
end
