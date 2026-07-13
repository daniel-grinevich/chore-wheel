class WeeksController < ApplicationController
  def show
    @week_start = parse_week(params[:week_start])
    @people = Person.order(:id).to_a
    @assignments = Assignment.for_week(@week_start)
                             .includes(:chore, :person, :work_sessions)
                             .scheduled_order
                             .to_a
    @days = (0...7).map { |i| @week_start + i }
    @assignments_by_day = @assignments.group_by(&:scheduled_on)

    @minutes_by_person = Hash.new(0)
    @assignments.each { |a| @minutes_by_person[a.person_id] += a.estimate_minutes }
  end

  def generate
    week_start = parse_week(params[:week_start])
    WeeklyAssigner.call(week_start: week_start)
    redirect_to week_path(week_start.iso8601), notice: "Chores assigned for the week."
  end

  private

  def parse_week(value)
    (value.present? ? Date.parse(value) : Date.current).beginning_of_week
  rescue ArgumentError, TypeError
    Date.current.beginning_of_week
  end
end
