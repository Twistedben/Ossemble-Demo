class Admins::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  before_action :loggout_user, only: [:create]
  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected
  
  # Below - If user is logs in as admin and is logged in as user, will log out of user
  def loggout_user 
    if current_user
      sign_out current_user 
    end 
  end 
  
  # Below - Method that redirects a user or admin after logging in to respective pages.
  def after_sign_in_path_for(resource)
    if resource == current_user # Person logging in is a user so sends to public city feed
      city_feed_path(current_user.city)
    elsif resource == current_admin # Person logging in has no workplaces they belong to so sends to new institute
      if current_admin.workplaces.empty?
        new_institute_path
      else # Admin has a workplace so sends to first one. TODO: CHange to list of workplaces they belong to
        workplace_feed_path(current_admin.institute, current_admin.main_workplace)
      end 
    end
  end  

  # Below - Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :user
      new_user_session_path
    elsif resource_or_scope == :admin
      new_admin_session_path
    else
      root_path
    end
  end
    

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  end
end
