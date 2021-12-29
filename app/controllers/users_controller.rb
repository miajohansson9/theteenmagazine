class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :find_user,
                only: %i[
                  show
                  edit
                  update
                  destroy
                  pageviews
                  share
                  redirect
                  get_editor_stats
                ]
  before_action :authenticate_user!,
                except: %i[index show redirect get_editor_stats]
  before_action :is_editor?, only: %i[show_users new]
  before_action :onboarding_redirect, if: :current_user?, only: [:show]
  before_action :is_admin?, only: %i[new partners]
  after_action :update_last_sign_in_at, if: :current_user?

  def show
    set_meta_tags title: "#{@user.full_name} | The Teen Magazine",
                  description: @user.description
    redirect_to "/partners/#{@user.slug}" if @user.partner
    @user_posts =
      Post
        .where('collaboration like ?', "%#{@user.email}%")
        .or(Post.where(user_id: @user.id))
        .distinct
        .order('updated_at desc')
    @user_posts_approved_records =
      Post
        .where('collaboration like ?', "%#{@user.email}%")
        .or(Post.where(user_id: @user.id))
        .published
        .by_published_date
    @pagy, @user_posts_approved =
      pagy(@user_posts_approved_records, page: params[:page], items: 10)
    if !@user.editor? && current_user.present?
      @user_pitches = @user.pitches.not_claimed.order('updated_at desc')
    elsif @user.editor?
      @editor_pitches_cnt = @user.pitches.count
      @editor_reviews = Review.where(editor_id: @user.id)
      @editor_reviews_cnt = @editor_reviews.count
      @writers_helped_cnt =
        @editor_reviews.map { |r| r.post.try(:user_id) }.uniq.count
    end
    if @user_posts_approved.length < 1
      begin
        if (
             current_user.id != @user.id && (!current_user.admin?) &&
               (!current_user.editor?)
           )
          redirect_to(
            :back,
            notice: 'This writer does not have a public profile yet.'
          )
        end
      rescue StandardError
        redirect_to(
          :back,
          notice: 'This writer does not have a public profile yet.'
        )
      end
    end
    if current_user.present?
      @pitches = Pitch.not_rejected.all.order('created_at desc').limit(4)
      @featured_writers =
        Post
          .where(publish_at: (Time.now - 7.days)..Time.now)
          .order('updated_at desc')
          .map { |p| p.user }
          .uniq
      @user_posts_approved_records.length < 1 ? new_writer : full_writer
    end
  end

  def get_profile
    @user = User.friendly.find(params[:id]) unless params[:id].nil?
    redirect_to "/writers/#{@user.slug}" unless @user.nil?
    redirect_to '/login'
  end

  def get_editor_stats
    @editor_pitches_cnt = @user.pitches.count
    @editor_reviews = Review.where(editor_id: @user.id)
    @editor_reviews_cnt = @editor_reviews.count
    @writers_helped_cnt =
      @editor_reviews.map { |r| r.post.try(:user_id) }.uniq.count
    render partial: 'users/partials/editor_stats'
  end

  def get_past_invites
    @user = User.find(params[:id])
    @per_page = 3
    @page = params[:page].nil? ? 2 : Integer(params[:page]) + 1
    @is_last_page =
      (@user.invitations.count - (@page - 2) * @per_page) <= @per_page
    @pagy, @invitations =
      pagy_countless(
        @user.invitations.order('created_at desc'),
        page: params[:page],
        items: @per_page,
        link_extra: 'data-remote="true"'
      )
    if params[:page].present?
      respond_to { |format| format.js }
    else
      render partial: 'users/dashboard/tabs/invites/all_past_invites'
    end
  end

  def get_published_articles
    @user = User.find(params[:id])
    @promotions = @user.promotions
    @per_page = 6
    @user_posts_approved_records =
      Post
        .where('collaboration like ?', "%#{@user.email}%")
        .or(Post.where(user_id: @user.id))
        .published
        .by_promoted_then_updated_date
    @page = params[:page].nil? ? 2 : Integer(params[:page]) + 1
    @is_last_page =
      (@user_posts_approved_records.count - (@page - 2) * @per_page) <=
        @per_page
    @pagy, @posts =
      pagy_countless(
        @user_posts_approved_records,
        page: params[:page],
        items: @per_page,
        link_extra: 'data-remote="true"'
      )
    if params[:page].present?
      respond_to { |format| format.js }
    else
      render partial: 'users/dashboard/tabs/articles/all_published_articles'
    end
  end

  def post_modal
    @user = User.find(params[:id])
    @post = Post.find(params[:post_id])
    respond_to do |format|
      format.html { redirect_to "/users/#{@post.user.slug}" }
      format.js
    end
  end

  def promote_post
    @user = User.find(params[:id])
    @post = Post.find(params[:post_id])
    if @post.user.promotions > 0
      @initial = @post.promoting_until || Time.now
      @post.update_column('promoting_until', @initial + 7.days)
      respond_to do |format|
        format.html { redirect_to "/users/#{@post.user.slug}" }
        format.js
      end
      @post.user.update_column('promotions', @post.user.promotions - 1)
    end
  end

  def onboarding_redirect
    if current_user.present? && (current_user.submitted_profile.eql? nil) &&
         (!current_user.partner)
      redirect_to '/onboarding',
                  notice: 'Please complete the onboarding process first.'
    end
  end

  def new_writer
    @has_completed_onboarding = !@user.submitted_profile.nil?
    @has_submitted_profile = !@user.submitted_profile.nil?
    @has_claimed_pitch = Pitch.where(claimed_id: @user.id).exists?
    @has_read_resources =
      @user.read_pitches && @user.read_articles && @user.read_images
    @has_submitted_first_draft = @user.posts.has_been_submitted.exists?
    @has_published = @user.posts.published.exists?
    @percent_complete =
      [
        @has_completed_onboarding,
        @has_submitted_profile,
        @has_claimed_pitch,
        @has_read_resources,
        @has_submitted_first_draft,
        @has_published
      ].count(true) / 6.0 * 100.0
    @show_onboarding =
      @user.last_saw_new_writer_dashboard.nil? &&
        (current_user.id.eql? @user.id)
    flash.now[:notice] = 'Writer dashboard unlocked!' if @show_onboarding
    if current_user.id.eql? @user.id
      @user.last_saw_new_writer_dashboard = Time.now
      @user.save
    end
  end

  def full_writer
    @invitation = Invitation.new
    @invitations_from_notice = @user.invitations.where(alert_viewed_at: nil, status: ["Accepted", "Applied"])
    @claimed_pitches_cnt = Pitch.where(claimed_id: @user.id)&.count || 0
    @pageviews = @user_posts_approved_records.sum(&:post_impressions)
    set_badges
    @show_onboarding_full =
      @user.last_saw_writer_dashboard.nil? && (current_user.id.eql? @user.id)
    @show_editor_onboarding =
      @user.became_an_editor.nil? && @user.editor &&
        (current_user.id.eql? @user.id) && !@show_onboarding_full
    if @show_onboarding_full
      @user.promotions = @user.promotions + 1
      @user.save
    end
    if @show_editor_onboarding
      @user.became_an_editor = Time.now
      @user.promotions = @user.promotions + 1
      @user.save
    elsif current_user.id.eql? @user.id
      @user.last_saw_writer_dashboard = Time.now
      @user.save
    end
  end

  def partner
    @partner = User.where(partner: true).find(params[:id])
    set_meta_tags title: "#{@partner.full_name} | The Teen Magazine"
    @posts = Post.where(partner_id: @partner.id).where(publish_at: nil)
    @published = Post.published.where(partner_id: @partner.id)
    @pageviews = @published.sum(&:post_impressions)
  end

  def sponsored
    @partner = User.where(partner: true).find(params[:id])
    set_meta_tags title:
                    "#{@partner.full_name} Published Articles | The Teen Magazine"
    @published = Post.published.where(partner_id: @partner.id)
  end

  def set_badges
    # if you want to change a badge color, you must update all the already created badges
    # to match the new color
    @levels = [
      ['500k+', '#1F2955', 500_000],
      ['300k+', '#6A198E', 300_000],
      ['100k+', '#a88beb', 100_000],
      ['50k+', '#a88beb', 50_000],
      ['20k+', '#00acee', 20_000],
      ['10k+', '#EF265F', 10_000],
      ['5,000+', '#4ABEB6', 5000],
      ['1,000+', '#4ABEB6', 1000]
    ]
    @levels.each_with_index do |level, index|
      if @user.badges.where(level: level[0]).present?
        @badge = @user.badges.find_by(level: level[0])
        break
      elsif (@pageviews >= level[2]) &&
            (@user.badges.where(level: level[0]).count.eql? 0) &&
            (current_user.id.eql? @user.id)
        @badge =
          @user.badges.build(
            level: level[0],
            kind: 'pageviews',
            color: level[1]
          )
        @badge.save
        @badges_above = @levels[0..index].map { |l| l[0] }
        @users_who_have_badge =
          User.includes(:badges).where(badges: { level: @badges_above }).count
        @percentile =
          (
            (
              @users_who_have_badge.to_f /
                (User.all.count - @users_who_have_badge)
            ) * 100
          ).round(1)
        @percentile = (@percentile < 0.1) ? '< 0.1' : @percentile
        @show_badge_popup = true
        break
      end
    end
    if !@badge.nil?
      @match = @levels.find { |b| b[0] == @badge.level }
      if @levels.index(@match) > 0
        @next_badge_to_earn = @levels[@levels.index(@match) - 1]
        @pageviews_away_from_new_badge =
          (@next_badge_to_earn[2] - @pageviews).abs
        @percent_to_next_level =
          (@match[2] - @pageviews_away_from_new_badge).abs.to_f /
            (@next_badge_to_earn[2] - @match[2]).to_f * 100
      else
        @next_badge_to_earn = @levels.first
        @pageviews_away_from_new_badge = 0
      end
    else
      @next_badge_to_earn = @levels.last
      @pageviews_away_from_new_badge = (@next_badge_to_earn[2] - @pageviews).abs
    end
  end

  def onboarding
    set_meta_tags title: 'Onboarding | The Teen Magazine',
                  onboarding: 'Turn off ads'
    @user = current_user
    @partial = params[:step] || 'welcome'
    @pitches =
      Pitch
        .is_approved
        .not_claimed
        .where(status: nil)
        .where('updated_at > ?', Time.now - 40.days)
        .order('updated_at desc')
        .paginate(page: params[:page], per_page: 9)
    @pitch =
      Pitch
        .where(claimed_id: current_user.id)
        .find_by(id: current_user.onboarding_claimed_pitch_id)
  end

  def editor_onboarding
    set_meta_tags title: 'Editor Onboarding | The Teen Magazine',
                  onboarding: 'Turn off ads'
    @user = current_user
    @partial = params[:step] || 'welcome'
    @categories = Category.active
    @reviews_requirement =
      Constant
        .find_by(name: '# of monthly reviews editors need to complete')
        .try(:value)
    @pitches_requirement =
      Constant
        .find_by(name: '# of monthly pitches editors need to complete')
        .try(:value)
    @max_reviews =
      Constant
        .find_by(name: 'max # of reviews per month for editors')
        .try(:value)
  end

  def index
    if params[:commit].eql? 'Send reset link'
      reset_email
    elsif current_user && (current_user.admin? || current_user.editor?)
      set_meta_tags title: 'Writers | The Teen Magazine'
      show_users
    elsif current_user
      redirect_to current_user, notice: 'You do not have access to this page.'
    else
      redirect_to '/login', notice: 'You must sign in before continuing.'
      store_location_for(:user, request.fullpath)
    end
  end

  def show_users
    if params[:search].present?
      @query = params[:search][:query]
      @pagy, @users =
        pagy(
          User
            .where(partner: [nil, false])
            .where('lower(full_name) LIKE ?', "%#{@query.downcase}%")
            .order('last_sign_in_at IS NULL, last_sign_in_at desc'),
          page: params[:page],
          items: 25
        )
    else
      @pagy, @users =
        pagy(
          User
            .where(partner: [nil, false])
            .order('last_sign_in_at IS NULL, last_sign_in_at desc'),
          page: params[:page],
          items: 25
        )
    end
    @users_waiting = User.all.review_profile
  end

  def partners
    set_meta_tags title: 'Partners | The Teen Magazine'
    if params[:search].present?
      @query = params[:search][:query]
      @pagy, @partners =
        pagy(
          User
            .where(partner: true)
            .where('lower(full_name) LIKE ?', "%#{@query.downcase}%"),
          page: params[:page],
          items: 25
        )
    else
      @pagy, @partners =
        pagy(
          User
            .where(partner: true)
            .order('created_at desc')
            .order('created_at desc'),
          page: params[:page],
          items: 25
        )
    end
  end

  def editors
    set_meta_tags title: 'Editors | The Teen Magazine'
    if params[:search].present?
      @query = params[:search][:query]
      @pagy, @editors =
        pagy(
          User
            .where(editor: true)
            .order('last_sign_in_at IS NULL, last_sign_in_at desc')
            .where('lower(full_name) LIKE ?', "%#{@query.downcase}%"),
          page: params[:page],
          items: 25
        )
    else
      @pagy, @editors =
        pagy(
          User
            .where(editor: true)
            .order('last_sign_in_at IS NULL, last_sign_in_at desc'),
          page: params[:page],
          items: 25
        )
    end
  end

  def reset_email
    begin
      User
        .where(email: params[:user][:email].strip)
        .first
        .send_reset_password_instructions
      redirect_to '/reset-password',
                  notice:
                    "A reset password email was sent to #{params[:user][:email]}."
    rescue StandardError
      redirect_to '/reset-password',
                  notice:
                    "Oops, something went wrong! #{params[:user][:email]} may not be associated with a writer account."
    end
  end

  def edit
    if @user.editor?
      @editor_pitches_cnt = @user.pitches.count
      @editor_reviews = Review.where(editor_id: @user.id)
      @editor_reviews_cnt = @editor_reviews.count
      @writers_helped_cnt =
        @editor_reviews.map { |r| r.post.try(:user_id) }.uniq.count
    end
    set_meta_tags title: 'Edit Profile | The Teen Magazine'
  end

  def new
    @user = User.new
    set_meta_tags title: 'New Partner | The Teen Magazine'
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if @user.partner
        ApplicationMailer.partner_login_details(current_user, @user).deliver
        redirect_to "/partners/#{@user.slug}",
                    notice: 'A new partner was added!'
      else
        redirect_to @user, notice: 'Your changes were successfully saved!'
      end
    else
      render 'new', notice: 'Oh no! Your changes were not able to be saved!'
    end
  end

  def update
    if @user.approved_profile == false && user_params[:approved_profile] == '1'
      ApplicationMailer.profile_approved(@user).deliver
    end
    if @user.update user_params
      if @user.first_name.present? && @user.last_name.present?
        @user.full_name = "#{@user.first_name} #{@user.last_name}"
        if !@user.editor
          @user.became_an_editor = nil
          @user.completed_editor_onboarding = nil
        end
        @user.save
      end
      if params[:redirect] != nil
        redirect_to onboarding_path(step: params[:redirect])
      elsif params[:decision].present?
        respond_to_editor_app
        redirect_to applies_path,
                    notice:
                      "Editor application #{params[:decision].downcase}ed."
      else
        add_to_list(@user)
        redirect_to @user, notice: 'Your profile has been updated.'
      end
    else
      render 'edit', notice: 'Changes were unable to be saved.'
    end
  end

  def respond_to_editor_app
    if params[:decision].eql? 'Accept'
      ApplicationMailer.accepted_editor_email(@user).deliver
      @user.editor = true
      @user.save
    elsif params[:decision].eql? 'Reject'
      ApplicationMailer.rejected_editor_email(@user).deliver
      @app = Apply.where(rejected_editor_at: nil, user_id: @user.id)
      @app.each do |app|
        if app.rejected_editor_at.nil?
          app.rejected_editor_at = Time.now
          app.save
        end
      end
    end
  end

  def destroy
    if @user.partner
      Post
        .where(partner_id: @user.id)
        .each do |post|
          post.partner_id = nil
          post.save
        end
    end
    @user.posts.each do |post|
      post.user = User.where(email: 'anonymous@theteenmagazine.com').first
      post.save
    end
    Pitch
      .where(claimed_id: @user.id)
      .where.not(editor_id: nil)
      .each do |pitch|
        pitch.claimed_id = nil
        pitch.save
      end
    @user.comments.destroy_all
    @user.destroy
    redirect_to users_path, notice: 'The writer account was deleted.'
  end

  def redirect
    if @user.partner
      redirect_to "/partners/#{@user.slug}"
    else
      redirect_to "/writers/#{@user.slug}"
    end
  end

  def share
    set_meta_tags title: 'Add Partner to Article | The Teen Magazine'
    @filtered_posts =
      current_user.admin? ? Post.draft : current_user.posts.draft
    if params[:search].present?
      @query = params[:search][:query]
      @pagy, @posts =
        pagy(
          @filtered_posts
            .where(partner_id: nil)
            .where('lower(title) LIKE ?', "%#{@query.downcase}%")
            .by_published_date,
          page: params[:page],
          items: 15
        )
    else
      @pagy, @posts =
        pagy(
          @filtered_posts.where(partner_id: nil).by_published_date,
          page: params[:page],
          items: 15
        )
    end
  end

  def extensions
    set_meta_tags title: 'Use an Extension | The Teen Magazine'
    @user = User.find(params[:id])
    if current_user.admin || (current_user.id.eql? @user.id)
      @extensions = @user.extensions || 0
      if params[:search].present?
        @query = params[:search][:query]
        @pagy, @posts =
          pagy(
            @user
              .posts
              .draft
              .distinct
              .where('lower(title) LIKE ?', "%#{@query.downcase}%")
              .where.not(deadline_at: nil, pitch_id: nil),
            page: params[:page],
            items: 15
          ).order('updated_at desc')
      else
        @pagy, @posts =
          pagy(
            @user
              .posts
              .draft
              .distinct
              .where.not(deadline_at: nil, pitch_id: nil)
              .order('updated_at desc'),
            page: params[:page],
            items: 15
          )
      end
    else
      redirect_to "/writers/#{current_user.slug}/extensions"
    end
  end

  def is_admin?
    if (current_user && current_user.admin?)
      true
    else
      redirect_to current_user, notice: 'You do not have access to this page.'
    end
  end

  def is_editor?
    if (current_user && (current_user.admin? || current_user.editor?))
      true
    else
      redirect_to current_user, notice: 'You do not have access to this page.'
    end
  end

  def current_user?
    current_user.present?
  end

  def set_layout
    current_user ? 'writer' : 'application'
  end

  def add_to_list(user)
    begin
      @gb = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
      @gb
        .lists(ENV['MAILCHIMP_LIST_ID'])
        .members
        .create(body: { email_address: user.email, status: 'subscribed' })
    rescue StandardError
      puts 'Error: Failed to subscribe to mailchimp list'
    end
  end

  def update_last_sign_in_at
    Thread.new { current_user.update_column('last_sign_in_at', Time.now) }
  end

  private

  def user_params
    params
      .require(:user)
      .permit(
        :email,
        :password,
        :onboarding_claimed_pitch_id,
        :do_not_send_emails,
        :editor,
        :partner,
        :full_name,
        :admin,
        :first_name,
        :last_name,
        :category,
        :points,
        :extensions,
        :promotions,
        :submitted_profile,
        :approved_profile,
        :nickname,
        :posts_count,
        :image,
        :description,
        :slug,
        :website,
        :unconfirmed_email,
        :monthly_views,
        :profile,
        :insta,
        :twitter,
        :facebook,
        :pintrest,
        :youtube,
        :snap,
        :bi_monthly_assignment,
        :last_saw_pitches,
        :last_saw_writer_applications,
        :last_saw_editor_dashboard,
        :last_saw_peer_feedback,
        :last_saw_community,
        :last_saw_new_writer_dashboard,
        :last_saw_writer_dashboard,
        :became_an_editor,
        :completed_editor_onboarding,
        :missed_editor_deadline,
        :notify_of_new_review,
        :has_newsletter_permissions,
        :skip_assignment
      )
  end

  def find_user
    @user = User.friendly.find(params[:id])
  end
end
