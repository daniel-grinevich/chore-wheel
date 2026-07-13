class Person < ApplicationRecord
  has_many :assignments, dependent: :destroy

  validates :name, presence: true
  validates :color, presence: true

  # Total estimated minutes assigned to this person for a given week.
  def assigned_minutes_for(week_start)
    assignments.where(week_start: week_start).sum(:estimate_minutes)
  end
end
