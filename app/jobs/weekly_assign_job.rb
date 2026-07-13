class WeeklyAssignJob < ApplicationJob
  queue_as :default

  # Generates assignments for the given week (defaults to the current week).
  # Idempotent via WeeklyAssigner, so running it again is a no-op.
  def perform(week_start = Date.current.beginning_of_week)
    week_start = Date.parse(week_start) if week_start.is_a?(String)
    WeeklyAssigner.call(week_start: week_start)
  end
end
