class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :followed, uniqueness: { scope: :follower }
  validate :must_not_yourself

  private

  def must_not_yourself
    errors.add(:followed, "must not yourself") if follower_id == followed_id
  end
end
