class Page < ApplicationRecord
    belongs_to :user
    belongs_to :category, optional: true

    attr_accessor :decision

    extend FriendlyId
    friendly_id :title, use: :history
end
