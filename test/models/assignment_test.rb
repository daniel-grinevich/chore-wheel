require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  def setup
    @person = Person.create!(name: "Tester", color: "#000000")
    @chore = Chore.create!(name: "Dishes", base_estimate_minutes: 20, active: true)
    @assignment = Assignment.create!(
      chore: @chore, person: @person,
      week_start: Date.current.beginning_of_week, scheduled_on: Date.current,
      estimate_minutes: 20
    )
  end

  test "start_timer! opens a running session and marks in_progress" do
    session = @assignment.start_timer!
    assert @assignment.timer_running?
    assert @assignment.in_progress?
    assert_nil session.ended_at
  end

  test "start_timer! is idempotent" do
    first = @assignment.start_timer!
    second = @assignment.start_timer!
    assert_equal first.id, second.id
    assert_equal 1, @assignment.work_sessions.count
  end

  test "stop_timer! records duration and marks done" do
    @assignment.start_timer!
    @assignment.active_session.update!(started_at: 5.minutes.ago)
    session = @assignment.stop_timer!

    assert @assignment.done?
    assert_not @assignment.timer_running?
    assert_in_delta 300, session.duration_seconds, 2
  end

  test "stop_timer! with no running session is a no-op" do
    assert_nil @assignment.stop_timer!
    assert @assignment.pending?
  end

  test "one chore per week is enforced" do
    dup = Assignment.new(
      chore: @chore, person: @person,
      week_start: @assignment.week_start, scheduled_on: Date.current, estimate_minutes: 20
    )
    assert_raises(ActiveRecord::RecordNotUnique) { dup.save!(validate: false) }
  end
end
