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

    def filtered_pitches
        @category_id = if (params[:pitch][:category_id].blank?)
            @categories.map { |category| category.id }
        else
            params[:pitch][:category_id]
        end
        @pitch = Pitch.new(category_id: params[:pitch][:category_id])
        @pagy, @pitches =
            pagy(
            Pitch
                .is_approved
                .not_claimed
                .where(category_id: @category_id, status: nil)
                .order("updated_at desc"),
            page: params[:page],
            items: 20,
            )
    end

    def all_pitches
        @pitch = Pitch.new
        @pagy, @pitches =
          pagy(
            Pitch
              .is_approved
              .not_claimed
              .where(status: nil)
              .where("updated_at > ?", Time.now - 90.days)
              .where.not(category_id: Category.find("interviews").id)
              .order("updated_at desc"),
            page: params[:page],
            items: 20,
          )
    end
end
