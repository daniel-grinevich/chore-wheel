class ChoresController < ApplicationController
  before_action :set_chore, only: [ :edit, :update, :destroy ]

  def index
    @chores = Chore.order(active: :desc, name: :asc)
  end

  def new
    @chore = Chore.new(active: true, base_estimate_minutes: 15)
  end

  def create
    @chore = Chore.new(chore_params)
    if @chore.save
      redirect_to chores_path, notice: "Added #{@chore.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @chore.update(chore_params)
      redirect_to chores_path, notice: "Updated #{@chore.name}."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @chore.destroy
    redirect_to chores_path, notice: "Removed #{@chore.name}."
  end

  private

  def set_chore
    @chore = Chore.find(params[:id])
  end

  def chore_params
    params.require(:chore).permit(:name, :base_estimate_minutes, :active)
  end
end
