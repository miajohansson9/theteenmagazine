class Invitation < ApplicationRecord
  belongs_to :user
  has_many :applies
end
