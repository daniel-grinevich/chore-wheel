require "test_helper"

class ChoreTest < ActiveSupport::TestCase
  def setup
    @person = Person.create!(name: "Tester", color: "#000000")
    @chore = Chore.create!(name: "Dishes", base_estimate_minutes: 20, active: true)
  end

  # Records a completed work session of `minutes` for the chore. Each call uses
  # a distinct week so it doesn't collide with the one-chore-per-week index.
  def log_session(minutes)
    @week_offset = (@week_offset || 0) + 1
    week = Date.current.beginning_of_week - (@week_offset * 7)
    assignment = Assignment.create!(
      chore: @chore, person: @person,
      week_start: week, scheduled_on: week,
      estimate_minutes: @chore.average_minutes
    )
    started = Time.current - 200.days + @week_offset.hours # monotonic: later calls end later
    assignment.work_sessions.create!(
      started_at: started, ended_at: started + minutes.minutes,
      duration_seconds: minutes * 60
    )
  end

  test "average_minutes falls back to base estimate with no history" do
    assert_equal 20, @chore.average_minutes
    assert_not @chore.estimate_from_history?
  end

  test "average_minutes becomes the rolling average of timed sessions" do
    log_session(6)
    log_session(10)
    assert_equal 8, @chore.reload.average_minutes # (6 + 10) / 2
    assert @chore.estimate_from_history?
  end

  test "average_minutes only uses the most recent RECENT_SAMPLE sessions" do
    # Older long sessions that should age out of the window.
    Chore::RECENT_SAMPLE.times { log_session(60) }
    # Then RECENT_SAMPLE short ones push the old ones out.
    Chore::RECENT_SAMPLE.times { log_session(2) }
    assert_equal 2, @chore.reload.average_minutes
  end

  test "difficulty is derived from the refined average" do
    assert_equal :medium, @chore.difficulty # base 20 -> medium
    log_session(5)
    assert_equal :easy, @chore.reload.difficulty
  end

  test "hard difficulty for long averages" do
    log_session(50)
    assert_equal :hard, @chore.reload.difficulty
  end

  test "active scope excludes inactive chores" do
    Chore.create!(name: "Retired", base_estimate_minutes: 5, active: false)
    assert_includes Chore.active, @chore
    assert_equal 1, Chore.active.count
  end
end
