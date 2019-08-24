class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  before_action :loggout_admin, only: [:create]
  class SessionsController < ApplicationController
    def create
      @user = User.find_or_create_from_auth_hash(auth_hash)
      self.current_user = @user
       # Below - Assigns lakewood to guest user unless their is a city in URL.
      @city = City.find(1) if is_guest? unless params[:city_id]
      # Below - Assigns @city as the user's city unless they're in a city.
      @city = current_or_guest_user.city if is_logged_in? unless params[:city_id] 
      # Below - Assigns lakewood to guest user 
      @city = City.find(params[:city_id]) if params[:city_id]
      redirect_to city_feed_path(@city)
    end
  
    protected
  
      def auth_hash
        request.env['omniauth.auth']
      end
  end # End of Sessions Controller
    
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected
  # Below - If user logs in as citizen and is logged in as admin, will log out of admin
  def loggout_admin
    if current_admin
      sign_out current_admin 
    end 
  end 
  # Below - Method that redirects a user or admin after logging in to respective pages.
  def after_sign_in_path_for(resource)
    unless is_guest?
      if resource == current_user
        city_feed_path(current_user.city)
      elsif resource == current_admin
        workplace_feed_path(resource.institute, resource.main_workplace)
      else 
        root_path
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
    
  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:login, keys: [:email, :password])
  end
end
