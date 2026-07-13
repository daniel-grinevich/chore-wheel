class WorkSession < ApplicationRecord
  belongs_to :assignment
  has_one :chore, through: :assignment

  validates :started_at, presence: true

  scope :completed, -> { where.not(duration_seconds: nil) }

  def running?
    ended_at.nil?
  end
end
