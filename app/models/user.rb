class User < ApplicationRecord
  has_many :sleeps, dependent: :destroy

  validates :name, presence: true
end
