class ApplicationMailer < ActionMailer::Base
  default from: "The Teen Magazine Editor Team <editors@theteenmagazine.com>"

  def custom_message_template(user, newsletter)
    @user = user
    @newsletter = newsletter
    mail(
      to: @user.email,
      subject: @newsletter.subject || @newsletter.header || "Message from The Teen Magazine",
    )
  end

  def welcome_email(user)
    @user = user
    mail(
      to: user.email,
      subject: "#{user.first_name}, Welcome to The Teen Magazine!",
    )
  end

  def rejection_email(user)
    @user = user
    mail(
      to: user.email,
      subject: "Your Application to The Teen Magazine Writer Team",
    )
  end

  def accepted_editor_email(user)
    @user = user
    mail(
      to: user.email,
      subject: "#{user.first_name}, Welcome to The Teen Magazine Editor Team!",
    )
  end

  def rejected_editor_email(user)
    @user = user
    mail(
      to: user.email,
      subject: "Your Application to The Teen Magazine Editor Team",
    )
  end

  def confirm_submitted_interview(contact_email, pitch)
    @pitch = pitch
    @contact_email = contact_email
    mail(
      to: contact_email,
      subject: "Your interview request to The Teen Magazine was submitted successfully",
    )
  end

  def manual_invite_interviewer(user)
    @user = user
    mail(
      to: user.email,
      subject: "Invitation to be on interview team",
      from: "Mia from The Teen Magazine <mia@theteenmagazine.com>",
    )
  end

  def profile_approved(user)
    @user = user
    unless @user.do_not_send_emails
      mail(
        to: user.email,
        subject: "#{user.first_name}, Your profile was approved!",
      )
    end
  end

  def first_article_published(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "Your first article was just published!")
    end
  end

  def article_published(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "You're published!")
    end
  end

  def interview_published(post)
    @post = post
    @pitch = post.pitch
    unless @pitch.nil?
      mail(to: @pitch.contact_email,
           subject: "Your interview is live!",
           from: "Mia from The Teen Magazine <mia@theteenmagazine.com>",
           cc: [@post.user.email, "Editors <editors@theteenmagazine.com>"])
    end
  end

  def article_moved_to_review(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(
        to: user.email,
        subject: "#{user.first_name}, Your article moved to in review.",
      )
    end
  end

  def article_moved_to_submitted(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(
        to: user.email,
        subject: "#{user.first_name}, Your article was submitted for review",
      )
    end
  end

  def article_has_requested_changes(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(
        to: user.email,
        subject: "#{user.first_name}, Your article has changes requested.",
      )
    end
  end

  def comment_added(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "A writer commented on your article.")
    end
  end

  def pitch_has_been_reviewed(user, pitch)
    @user = user
    @pitch = pitch
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "There are changes on your pitch.")
    end
  end

  def article_deadline_warning(user, posts)
    @user = user
    @posts = posts
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "You have drafts due soon")
    end
  end

  def article_deadline_passed(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "Your article has passed its due date")
    end
  end

  def send_pitches(email, pitches)
    @pitches = pitches
    mail(to: email, subject: "Get Inspired by These Topic Ideas")
  end

  def invitation_to_apply(email, user, invite)
    @user = user
    @invitation = invite
    mail(
      to: email,
      subject: "#{@user.first_name} recommended you to join The Teen Magazine",
    )
  end

  def new_badge_earned(user, badge)
    @badge = badge
    @user = user
    unless user.do_not_send_emails
      mail(to: user.email, subject: "You have an unclaimed badge!")
    end
  end

  def remind_editors_of_assigments(user)
    @user = user
    @reviews_requirement =
      Integer(
        Constant
          .find_by(name: "# of monthly reviews editors need to complete")
          .try(:value) || "0"
      )
    @pitches_requirement =
      Integer(
        Constant
          .find_by(name: "# of monthly pitches editors need to complete")
          .try(:value) || "0"
      )
    @month = Date.today.strftime("%B")
    @gifs = %w[
      https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy.gif
      https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-5.gif
      https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-17.gif
      http://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-13.gif
      http://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-12.gif
      https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-9.gif
      https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-8.gif
      https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-10.gif
      https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-3.gif
      https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-4.gif
      https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-16.gif
      https://s3.amazonaws.com/media.theteenmagazine.com/months/giphy-1.gif
    ]
    unless @user.do_not_send_emails
      mail(
        to: user.email,
        subject: "#{user.first_name}, here are the editor assignments for #{Date.today.in_time_zone.strftime("%B")}",
        from: "Mia from The Teen Magazine <mia@theteenmagazine.com>",
      )
    end
  end

  def editor_warning_deadline_1(
    user,
    reviews_requirement,
    pitches_requirement,
    editor_pitches_cnt,
    editor_reviews_cnt
  )
    @user = user
    @month = Date.yesterday.strftime("%B")
    @reviews_requirement = reviews_requirement
    @pitches_requirement = pitches_requirement
    @editor_pitches_cnt = editor_pitches_cnt
    @editor_reviews_cnt = editor_reviews_cnt
    unless @user.do_not_send_emails
      mail(
        to: user.email,
        subject: "#{user.first_name}, you are not on track to completing your editor assignments",
        from: "Mia from The Teen Magazine <mia@theteenmagazine.com>",
      )
    end
  end

  def editor_warning_deadline_2(
    user,
    reviews_requirement,
    pitches_requirement,
    editor_pitches_cnt,
    editor_reviews_cnt
  )
    @user = user
    @month = Date.yesterday.strftime("%B")
    @reviews_requirement = reviews_requirement
    @pitches_requirement = pitches_requirement
    @editor_pitches_cnt = editor_pitches_cnt
    @editor_reviews_cnt = editor_reviews_cnt
    unless @user.do_not_send_emails
      mail(
        to: user.email,
        subject: "#{user.first_name}, you are not on track to completing your editor assignments",
        from: "Mia from The Teen Magazine <mia@theteenmagazine.com>",
      )
    end
  end

  def editor_missed_deadline_1(
    user,
    reviews_requirement,
    pitches_requirement,
    editor_pitches_cnt,
    editor_reviews_cnt
  )
    @user = user
    @month = Date.yesterday.strftime("%B")
    @reviews_requirement = reviews_requirement
    @pitches_requirement = pitches_requirement
    @editor_pitches_cnt = editor_pitches_cnt
    @editor_reviews_cnt = editor_reviews_cnt
    unless @user.do_not_send_emails
      mail(
        to: user.email,
        subject: "#{user.first_name}, you missed the editor deadline for #{@month}",
        from: "Mia from The Teen Magazine <mia@theteenmagazine.com>",
        cc: ["Editors <editors@theteenmagazine.com>"],
      )
    end
  end

  def removed_editor_from_team(user)
    @user = user
    @editor_pitches_cnt = @user.pitches.count
    @editor_reviews = Review.where(editor_id: @user.id)
    @editor_reviews_cnt = @editor_reviews.count
    @writers_helped_cnt =
      @editor_reviews.map { |r| r.post.try(:user_id) }.uniq.count
    unless @user.do_not_send_emails
      mail(
        to: user.email,
        subject: "#{user.first_name}, you were removed from the editor team",
        from: "Mia from The Teen Magazine <mia@theteenmagazine.com>",
        cc: ["Editors <editors@theteenmagazine.com>"],
      )
    end
  end

  def notify_editor_that_article_moved_to_review(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(
        to: user.email,
        subject: "A new article was submitted for review on The Teen Magazine",
      )
    end
  end

  def editor_missed_review_deadline(user, post)
    @user = user
    @post = post
    unless @user.do_not_send_emails
      mail(to: user.email, subject: "Your review is overdue", cc: ["Editors <editors@theteenmagazine.com>"])
    end
  end

  def partner_login_details(user, partner)
    @user = user
    @partner = partner
    mail(to: user.email, subject: "#{partner.full_name} login info")
  end

  def featured_article(user, post)
    @user = user
    @post = post
    mail(
      to: user.email,
      subject: "#{@user.first_name}, congratulations! Your article is featured",
    )
  end

  def weekly_newsletter(email, newsletter)
    @newsletter = newsletter
    mail(to: email, subject: @newsletter.posts.last.title)
  end

  def featured_in_newsletter(user, post)
    @user = user
    @post = post
    mail(
      to: @user.email,
      subject: "#{@user.first_name}, congratulations! Your article was chosen for this week's newsletter!",
    )
  end

  def pitch_deleted(user, pitch)
    @user = user
    @pitch = pitch
    if @user
      mail(
        to: @user.email,
        subject: "#{@user.first_name}, your pitch was deleted by an admin",
      )
    end
  end

  private

  helper_method def indefinite_articlerize(params_word)
    %w(a e i o u).include?(params_word[0].downcase) ? "an" : "a"
  end

  helper_method def markdown(content)
    renderer =
      Redcarpet::Render::HTML.new(
        hard_wrap: true,
        autolink: true,
        no_intra_empasis: true,
        disable_indented_code_blocks: true,
        fenced_code_blocks: true,
        strikethough: true,
        superscirpt: true,
      )
    Redcarpet::Markdown.new(renderer).render(content).html_safe
  end
end
