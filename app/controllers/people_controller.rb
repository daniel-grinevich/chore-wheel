class PeopleController < ApplicationController
  before_action :set_person, only: [ :edit, :update ]

  def index
    @people = Person.order(:id)
  end

  def edit; end

  def update
    if @person.update(person_params)
      redirect_to people_path, notice: "Updated #{@person.name}."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:name, :color)
  end
end
