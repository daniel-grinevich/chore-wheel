class Assignment < ApplicationRecord
  belongs_to :chore
  belongs_to :person
  has_many :work_sessions, dependent: :destroy

  enum :status, { pending: 0, in_progress: 1, done: 2 }

  validates :week_start, presence: true
  validates :scheduled_on, presence: true

  scope :for_week, ->(week_start) { where(week_start: week_start) }
  scope :scheduled_order, -> { order(:scheduled_on, :id) }

  # The currently-running timer session, if any.
  def active_session
    work_sessions.find_by(ended_at: nil)
  end

  def timer_running?
    active_session.present?
  end

  # Total timed seconds across all completed sessions for this assignment.
  def total_seconds
    work_sessions.where.not(duration_seconds: nil).sum(:duration_seconds)
  end

  # Begin a timing session. Idempotent: returns the running session if one is
  # already going.
  def start_timer!
    return active_session if timer_running?

    transaction do
      in_progress!
      work_sessions.create!(started_at: Time.current)
    end
  end

  # End the running session, recording its duration. This is what refines the
  # chore's average_minutes / difficulty over time.
  def stop_timer!
    session = active_session
    return unless session

    transaction do
      session.update!(
        ended_at: Time.current,
        duration_seconds: (Time.current - session.started_at).round
      )
      done!
    end
    session
  end
end
