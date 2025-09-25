class User::Sleep < ApplicationRecord
  belongs_to :user

  validates :start_time, presence: true
  validate :end_time_after_start_time, if: :end_time_present?

  scope :ordered, -> { order(start_time: :desc) }
  scope :ranked, -> { where.not(end_time: nil).order(duration: :desc, id: :asc) }
  scope :recent, -> { where(start_time: 1.week.ago.beginning_of_week..) }
  scope :between, ->(start_time:, end_time:) { where(start_time: start_time..end_time) }

  before_save :set_duration

  private


  # TODO: Validate user sleep duration with MINIMUM_DURATION,
  # can also limit the rate at which users can store excessive sleep session data.
  def set_duration
    duration = 0

    if start_time.present? && end_time.present?
      duration = end_time - start_time
    end

    self.duration = duration
  end

  def end_time_after_start_time
    return unless start_time.present? && end_time.present?

    unless end_time > start_time
      errors.add(:end_time, "must be greater than #{start_time}")
    end
  end

  def end_time_present?
    end_time.present?
  end
end
