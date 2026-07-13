class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_person

  # The person the browser has identified as ("who am I"), stored in session.
  # No real auth — it's a private, two-person app on the tailnet.
  def current_person
    @current_person ||= Person.find_by(id: session[:person_id])
  end
end
