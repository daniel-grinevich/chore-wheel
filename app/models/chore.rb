class Chore < ApplicationRecord
  has_many :assignments, dependent: :destroy
  has_many :work_sessions, through: :assignments

  validates :name, presence: true
  validates :base_estimate_minutes, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  # How many of the most recent completed timings feed the rolling average.
  RECENT_SAMPLE = 10

  # Rolling average of actual timed durations (in minutes), falling back to the
  # manual base estimate until real timing history exists. This is the value
  # that "refines over time" as work sessions accumulate, and it feeds next
  # week's fairness math.
  def average_minutes
    durations = recent_durations_seconds
    return base_estimate_minutes if durations.empty?

    (durations.sum.to_f / durations.size / 60.0).round.clamp(1, nil)
  end

  # Difficulty bucket derived from the refined average. Shifts automatically as
  # real timings come in — no manual grading needed.
  def difficulty
    case average_minutes
    when 0...15 then :easy
    when 15...45 then :medium
    else :hard
    end
  end

  # Whether the average is still just the manual guess (no timings yet).
  def estimate_from_history?
    recent_durations_seconds.any?
  end

  private

  def recent_durations_seconds
    work_sessions
      .where.not(duration_seconds: nil)
      .order(ended_at: :desc)
      .limit(RECENT_SAMPLE)
      .pluck(:duration_seconds)
  end
end
