class User < ApplicationRecord
  has_many :sleeps, dependent: :destroy
  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :followees, through: :follows, source: :followed
  has_many :followees_sleeps, through: :followees, source: :sleeps
  has_many :being_follows, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :being_follows, source: :follower
  has_many :recent_followee_sleeps, foreign_key: :follower_id, dependent: :destroy

  validates :name, presence: true

  def followee_sleeps
    followed_ids = Follow.where(follower: self).pluck(:followed_id)

    User::Sleep
      .where(user_id: followed_ids)
  end
end
