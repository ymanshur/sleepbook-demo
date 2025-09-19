class User::Sleep < ApplicationRecord
  belongs_to :user

  validates :start_time, presence: true
  validates :end_time, comparison: { greater_than: :start_time }, if: :end_time_present?

  before_save :set_duration

  private

  def set_duration
    duration = 0

    if start_time.present? && end_time.present?
      duration = end_time - start_time
    end

    self.duration = duration
  end

  def end_time_present?
    end_time.present?
  end
end
