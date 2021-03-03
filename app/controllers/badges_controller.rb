class BadgesController < ApplicationController
  before_action :find_badge, only: [:destroy, :update, :edit]

  def destroy
    @badge.destroy
  end

  def create
    @user = User.find(params: id)
    @badge = @user.badges.build(badge_params)
    @badge.save
  end

  def update
    @badge.update(badge_params)
  end

  private

  def find_badge
    @badge = badge.find(params[:id])
  end

  def badge_params
    params.require(:badge).permit(:created_at, :id, :level, :user_id, :activated)
  end
end
