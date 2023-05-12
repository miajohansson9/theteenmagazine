class ActivitiesController < ApplicationController
  def create
    @activity = Activity.new(activity_params)
    @activity.save
  end

  private

  def activity_params
    params
      .require(:activity)
      .permit(:id, :action_at, :kind, :kind_id, :action, :user_id, :category_id)
  end
end
