class Subscriber < ApplicationRecord
    belongs_to :user, optional: true
end
