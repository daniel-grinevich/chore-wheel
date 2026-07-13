require "test_helper"

class WeeklyAssignerTest < ActiveSupport::TestCase
  def setup
    @week = Date.current.beginning_of_week
    @alice = Person.create!(name: "Alice", color: "#111111")
    @bob   = Person.create!(name: "Bob", color: "#222222")
  end

  def create_chores(minutes)
    minutes.each_with_index do |m, i|
      Chore.create!(name: "Chore #{i}", base_estimate_minutes: m, active: true)
    end
  end

  test "assigns every active chore exactly once" do
    create_chores([ 10, 20, 30, 40 ])
    created = WeeklyAssigner.call(week_start: @week)
    assert_equal 4, created.size
    assert_equal Chore.active.pluck(:id).sort, created.map(&:chore_id).sort
  end

  test "balances total minutes between people" do
    create_chores([ 45, 40, 30, 20, 15, 10, 5 ]) # total 165, ideal split ~82/83
    WeeklyAssigner.call(week_start: @week)

    a = @alice.assigned_minutes_for(@week)
    b = @bob.assigned_minutes_for(@week)
    assert_equal 165, a + b
    # Greedy LPT keeps the two totals close; allow the largest single chore as slack.
    assert_operator (a - b).abs, :<=, 45
  end

  test "skips chores that are inactive" do
    create_chores([ 10, 20 ])
    Chore.create!(name: "Inactive", base_estimate_minutes: 99, active: false)
    created = WeeklyAssigner.call(week_start: @week)
    assert_equal 2, created.size
    assert_not_includes created.map { |a| a.chore.name }, "Inactive"
  end

  test "is idempotent - does not double-assign for the same week" do
    create_chores([ 10, 20, 30 ])
    WeeklyAssigner.call(week_start: @week)
    WeeklyAssigner.call(week_start: @week)
    assert_equal 3, Assignment.for_week(@week).count
  end

  test "uses refined average over base estimate once history exists" do
    chore = Chore.create!(name: "Learned", base_estimate_minutes: 60, active: true)
    # Log a short real session so the refined average (2 min) beats the 60 guess.
    past = Assignment.create!(chore: chore, person: @alice,
      week_start: @week - 7, scheduled_on: @week - 7, estimate_minutes: 60)
    past.work_sessions.create!(started_at: 2.minutes.ago, ended_at: Time.current, duration_seconds: 120)

    created = WeeklyAssigner.call(week_start: @week)
    assert_equal 2, created.first.estimate_minutes # snapshot uses refined value
  end

  test "returns empty when there are no active chores" do
    assert_equal [], WeeklyAssigner.call(week_start: @week)
  end
end
