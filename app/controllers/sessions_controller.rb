class SessionsController < ApplicationController
  # Record "who am I" for this browser. No password — private tailnet app.
  def identify
    person = Person.find(params[:person_id])
    session[:person_id] = person.id
    redirect_back fallback_location: root_path, notice: "You are #{person.name}."
  end
end
