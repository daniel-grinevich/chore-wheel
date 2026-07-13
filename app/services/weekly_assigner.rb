# Assigns the active chores for a given week between the people, randomized but
# balanced so each person ends up with roughly equal total *minutes*.
#
# Strategy: greedy Longest-Processing-Time (LPT). Shuffle for randomness, then
# hand out chores largest-first, each to whoever currently has the fewest
# accumulated minutes. LPT keeps the two totals close. Chore "size" is the
# refined Chore#average_minutes, so the split gets smarter as timing history
# accumulates.
#
# Idempotent: if any assignments already exist for the week it does nothing, so
# a manual "Generate this week" click and the Monday cron can't double up.
class WeeklyAssigner
  DAYS_IN_WEEK = 7

  def self.call(week_start: Date.current.beginning_of_week)
    new(week_start: week_start).call
  end

  def initialize(week_start:)
    @week_start = week_start
  end

  def call
    return Assignment.for_week(@week_start).to_a if already_generated?

    people = Person.order(:id).to_a
    return [] if people.empty?

    chores = Chore.active.to_a
    return [] if chores.empty?

    # Largest estimated chores first; shuffle first so equal-sized chores (and
    # the whole set when there's no history yet) are handed out in random order.
    ordered = chores.shuffle.sort_by { |chore| -chore.average_minutes }

    minutes = people.index_with { 0 }
    day_cursor = 0
    created = []

    Assignment.transaction do
      ordered.each do |chore|
        person = people.min_by { |p| minutes[p] }
        estimate = chore.average_minutes
        minutes[person] += estimate

        created << Assignment.create!(
          chore: chore,
          person: person,
          week_start: @week_start,
          scheduled_on: @week_start + (day_cursor % DAYS_IN_WEEK),
          estimate_minutes: estimate,
          status: :pending
        )
        day_cursor += 1
      end
    end

    created
  end

  private

  def already_generated?
    Assignment.for_week(@week_start).exists?
  end
end
