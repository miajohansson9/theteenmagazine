class ContactsController < ApplicationController
  before_action :show

  def show
    set_meta_tags title: 'The Teen Magazine | Contact Us'
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    @contact.request = request
    if @contact.deliver
      flash.now[:error] = nil
    else
      flash.now[:error] = 'Cannot send message.'
      render :new
    end
  end
end
