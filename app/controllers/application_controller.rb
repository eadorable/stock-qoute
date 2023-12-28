class ApplicationController < ActionController::Base
  # route to login page after sign out
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
