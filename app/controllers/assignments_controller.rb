class AssignmentsController < ApplicationController
  before_action :set_assignment

  def start_timer
    @assignment.start_timer!
    respond_with_card
  end

  def stop_timer
    @assignment.stop_timer!
    respond_with_card
  end

  # Hand the chore to the other person.
  def reassign
    other = Person.where.not(id: @assignment.person_id).order(:id).first
    @assignment.update!(person: other) if other
    respond_with_card
  end

  private

  def set_assignment
    @assignment = Assignment.includes(:chore, :person, :work_sessions).find(params[:id])
  end

  def respond_with_card
    respond_to do |format|
      format.turbo_stream { render "assignments/card_update" }
      format.html { redirect_back fallback_location: root_path }
    end
  end
end
