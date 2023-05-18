class SubscribersController < ApplicationController
  before_action :find_subscriber, except: %i[new create index]
  before_action :is_admin?
  before_action :authenticate_user!
  load_and_authorize_resource

  def new
    @subscriber = Subscriber.new
    set_meta_tags title: "New Subscriber Field"
  end

  def edit
    set_meta_tags title: "Edit Subscriber Field"
  end

  def index
    @pagy, @subscribers =
      pagy(
        Subscriber.order("updated_at desc"),
        page: params[:page],
        items: 40,
      )
    set_meta_tags title: "Subscribers"
  end

  def update
    puts subscriber_params
    puts "LSKDJFLSKDJf"
    if @subscriber.update subscriber_params
      @subscriber.save
      redirect_to subscribers_path, notice: "Your changes were saved."
    else
      render "edit", notice: "Oops, something went wrong."
    end
  end

  def create
    if @subscriber.save
      redirect_to subscribers_path,
                  notice: "The subscriber was successfully added!"
    else
      render "new", notice: "Oh no! Your changes were not able to be saved!"
    end
  end

  def is_admin?
    unless (current_user && current_user.admin?)
      redirect_to root_path, notice: "You do not have access to this page."
    end
  end

  private

  def subscriber_params
    params
      .require(:subscriber)
      .permit(:id,
              :created_at,
              :updated_at,
              :email,
              :last_email_sent_at,
              :first_name,
              :last_name,
              :user_id,
              :token,
              :source,
              :opted_in_at,
              :subscribed_to_reader_newsletter,
              :subscribed_to_writer_newsletter,
              category_ids: [])
  end

  def find_subscriber
    @subscriber = Subscriber.find(params[:id])
  end
end
