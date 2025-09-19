class User < ApplicationRecord
  validates :name, presence: true

  has_many :sleeps, dependent: :destroy
end
