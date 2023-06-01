module PitchesHelper
  def your_claimed_pitches
    @title = "Your Claimed Pitches"
    set_meta_tags title: @title
    @button_text = "View Pitch"
    @message = "You don't have any claimed pitches. :("
    @pagy, @pitches =
      pagy(
        Pitch.where(claimed_id: params[:user_id]).order("updated_at desc"),
        page: params[:page],
        items: 20,
      )
  end

  def pitches_helper(pitches)
    @tab = params[:tab]
    @pitches = pitches
    @pagy_all, @pitches_all =
      pagy(@pitches,
           page_param: :page,
           params: ->(params) { params.merge!("tab" => "all") },
           items: 20)
    @pagy_high_priority, @pitches_high_priority =
      pagy(@pitches.where(priority: "High"),
           page_param: :page_high_priority,
           params: ->(params) { params.merge!("tab" => "high") },
           items: 20)
  end

  def all_interviews
    @pagy, @pitches =
      pagy(
        Pitch
          .is_approved
          .not_claimed
          .where(category_id: Category.find("interviews").id, status: nil)
          .order("updated_at desc"),
        page: params[:page],
        items: 20,
      )
    pitches_helper(@pitches)
  end

  def all_pitches
    @pitch = Pitch.new
    @pitches = Pitch
      .is_approved
      .not_claimed
      .where(status: nil)
      .where("updated_at > ?", Time.now - 90.days)
      .where.not(category_id: Category.find("interviews").id)
      .order("updated_at desc")
    pitches_helper(@pitches)
  end

  def filtered_pitches
    @category_id = if (params[:pitch][:category_id].blank?)
        @categories.map { |category| category.id }
      else
        params[:pitch][:category_id]
      end
    @pitch = Pitch.new(category_id: params[:pitch][:category_id])
    @pitches = Pitch
      .is_approved
      .not_claimed
      .where(category_id: @category_id, status: nil)
      .order("updated_at desc")
    pitches_helper(@pitches)
  end
end
