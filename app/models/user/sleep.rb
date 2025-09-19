class User::Sleep < ApplicationRecord
  validates :start_time, presence: true

  belongs_to :user

  before_save :set_duration

  private

  def set_duration
    duration = 0

    if start_time.present? && end_time.present?
      duration = end_time - start_time
    end

    self.duration = duration
  end
end
