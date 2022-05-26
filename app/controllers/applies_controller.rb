class AppliesController < ApplicationController
  before_action :authenticate_user!, except: %i[index new create]
  before_action :is_admin?, only: [:show]

  #show all applications
  def index
    if (current_user && current_user.admin?)
      set_meta_tags title: 'Writer Applications | The Teen Magazine'
      @notifications = @notifications - @unseen_applications_cnt
      @unseen_applications_cnt = 0
      @pagy, @applies =
        pagy(
          Apply
            .where(rejected_writer_at: nil, rejected_editor_at: nil)
            .order('updated_at desc'),
          page: params[:page],
          items: 20
        )
      Thread.new do
        current_user.update_column('last_saw_writer_applications', Time.now)
      end
    elsif current_user
      redirect_to '/applications/editor'
    else
      redirect_to '/apply'
    end
  end

  #create a new application
  def new
    @application = Apply.new
    set_meta_tags title: 'Apply',
                  description:
                    'Our writer team is made up of hundreds of college and high school writers from around the world who are passionate about improving their writing skills and are excited to connect with other like-minded writers. Apply to our team!',
                  image:
                    'https://www.theteenmagazine.com/assets/become_writer-4c75511ff2d771fd380fad4dcdbeeef932870882239e52252cbea070a877761e.jpg',
                  fb: {
                    app_id: '1190455601051741'
                  },
                  og: {
                    image: {
                      url:
                        'https://www.theteenmagazine.com/assets/become_writer-4c75511ff2d771fd380fad4dcdbeeef932870882239e52252cbea070a877761e.jpg',
                      alt: 'The Teen Magazine'
                    },
                    site_name: 'The Teen Magazine'
                  },
                  article: {
                    publisher: 'https://www.facebook.com/theteenmagazinee'
                  },
                  twitter: {
                    card: 'summary_large_image',
                    site: '@theteenmagazin_',
                    title: 'The Teen Magazine',
                    description:
                      'Our writer team is made up of hundreds of college and high school writers from around the world who are passionate about improving their writing skills and are excited to connect with other like-minded writers. Apply to our team!',
                    image:
                      'https://www.theteenmagazine.com/assets/become_writer-4c75511ff2d771fd380fad4dcdbeeef932870882239e52252cbea070a877761e.jpg',
                    domain: 'https://www.theteenmagazine.com/'
                  }
  end

  def update
    @application = Apply.find(params[:id])
    if @application.validate && @application.update(apply_params)
      app_submitted
    else
      render 'editor', notice: 'Oh no! Your changes were not able to be saved!'
    end
  end

  #send submitted application
  def create
    @application = Apply.new(apply_params)
    if @application.validate && @application.save
      app_submitted
    elsif apply_params[:user_id].present?
      render 'editor', notice: 'Oh no! Your changes were not able to be saved!'
    else
      render 'new', notice: 'Oh no! Your changes were not able to be saved!'
    end
  end

  def app_submitted
    set_meta_tags title: 'Application Submitted'
    if apply_params[:user_id].present?
      @editor_app = true
      @application.request = request
      if @application.validate && @application.deliver
        flash.now[:error] = nil
      else
        flash.now[:error] =
          "An error occured. Please check that you've filled out all the fields."
        render :editor
      end
    else
      @editor_app = false
      @application.request = request
      if @application.validate && @application.deliver
        flash.now[:error] = nil
      else
        flash.now[:error] =
          "An error occured. Please check that you've filled out all the fields."
        render :new
      end
    end
  end

  def editor
    @application =
      Apply.where(rejected_editor_at: nil).find_by(user_id: current_user.id) ||
        current_user.applies.build
    @applied_num_times =
      Apply.where(user_id: current_user.id, kind: 'Editor').count
    set_meta_tags title: 'Editor Application | The Teen Magazine',
                  description:
                    'Our editor team is in charge of pitching new article topics, publishing/giving feedback to articles, and responding to profile submissions. We are active on Slack and support each other in helping our writer team succeed at The Teen Magazine.'
  end

  #only allow admin and editors to see submitted applications
  def is_admin?
    if (current_user && (current_user.admin? || current_user.editor?))
      true
    else
      redirect_to current_user, notice: 'You do not have access to this page.'
    end
  end

  #show application to editor
  #form for creating a new user already filled out
  def show
    @application = Apply.find(params[:id])
    @invitation = @application.invitation

    # form for new user
    # when submit form, goes to registrations_controller
    @user = User.find_by(id: @application.user_id) || User.new
  end

  def destroy
    @application = Apply.find(params[:id])
    @application.destroy
    redirect_to applies_path, notice: 'Application deleted. No email was sent.'
  end

  private

  def apply_params
    params
      .require(:apply)
      .permit(
        :email,
        :first_name,
        :last_name,
        :nickname,
        :description,
        :sample_writing,
        :resume,
        :grade,
        :user_id,
        :editor_revision,
        :editor_feedback,
        :editor_pitches,
        :kind,
        :rejected_writer_at,
        :rejected_editor_at,
        :invitation_id
      )
  end
end
