class ApplicationController < ActionController::Base
  respond_to :html, :json
# Below - Initializes Pundit for controllers
  include Pundit 
# Below - Initializes Public Activity so current_user can be invoked away from user model, to allow setting of owner when activity is created.
  include PublicActivity::StoreController
# Below - Imports the Badges Helper which will take care the gamification function 
  include BadgesHelper
# Below - Protects from cross site request forgery and raises and exception.
  protect_from_forgery with: :null_session
# Below - Strong params before action for devise controllerss.
  #before_action :configure_permitted_parameters, if: :devise_controller?
# Below - Sets up Helper Methods for various method statuses.
  helper_method :current_users_city, :logged_in?, :current_city, :current_workplace, :current_institute, :hometown?, :is_admin?, 
    :is_mod?, :is_guest?, :is_logged_in?, :is_logged_and_hometown?, :is_logged_not_hometown?, :user_is_valid?, :user_not_valid?, :is_admins_city?, 
    :is_city_admin?, :current_user_or_admin, :is_admin_resource?, :is_workplace_page?, :is_current_super_admin?  #, :current_admin_check? #:current_user


# Begin - Setting up a guest user
  # Below - Sets up Guest and Current User
    # if user is logged in, return current_user, else return guest_user
=begin 
  def current_or_guest_user
    if current_user
      if session[:user_id] && session[:user_id] != current_user.id
        logging_in
        # reload guest_user to prevent caching problems before destruction
        guest_user(with_retry = false).try(:reload).try(:destroy)
        session[:user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end
  
  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user(with_retry = true)
    # Cache the value the first time it's gotten.
    @cached_guest_user ||= User.find(session[:user_id] ||= create_guest_user.id)
    rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
    session[:user_id] = nil
    guest_user if with_retry
  end
# End - Setting up a guest user
=end 
# Begin - Helper methods for application with calls.
  # Below - Finds the city the user belongs to.
    #def current_users_city
    #  current_or_guest_user.city.name
    #end
  # Below - Returns user if it's a citizen user, returns admin if it's a city user.
    def current_user_or_admin
      if current_user 
        return current_user
      elsif current_admin 
        return current_admin
      end 
    end
  # Below - finds current city from URL.
    def current_city
      if @city 
        @city.name
      elsif @institute
        @institute.name
      else #failsafe
      end
    end
    # Below -  Returns institute name from url
    def current_institute 
      if @institute 
        @institute.name
      else #Fail safe 
      end
    end   
  # Below - finds current workplace from URL.
    def current_workplace
      if @workplace && current_admin
        @workplace.name
      else#fail safe
      end 
    end
    
=begin
  # Below - Checks if current User belongs to current city.
    def hometown?
      current_or_guest_user.city == @city
    end
    
    
    # Below - Checks if user is a mod.
    def is_mod?
      current_or_guest_user.mod?
    end
    
    # Below - Ensures user is a guest and also not an admin.
    def is_guest?
      return true if current_or_guest_user.guest? == true && !current_admin
    end
     

    # Below - Ensures user is city admin
    def is_city_admin? 
      return true if current_admin
    end   
    
    # Below - Ensures admin is the current city admin
    def is_admins_city? 
      return true if current_admin && current_admin.city == @city

    end   
    
    # Below - Ensures user is logged in and in their hometown. Or is an admin in their own town. Or is a guest. Used primarily for upvoting.
    def is_logged_and_hometown?
      return true if (current_or_guest_user.guest? == false && current_or_guest_user.city == @city) || (current_admin && current_admin.city == @city)
    end 
    
    
    # Below - Checks if user is logged in but not in their hometown. 
    def is_logged_not_hometown?
      return true if (current_or_guest_user.guest? == false && current_or_guest_user.city != @city) || (current_admin && current_admin.city != @city) 
    end 
    
    # Below - Ensures user is valid, having filled out all the validatable attributes.
    def user_is_valid?
      return true if current_or_guest_user.valid?
    end   
    
    # Below - Ensures user is not valid.
    def user_not_valid?
      return true if current_or_guest_user.valid? == false
    end 
=end
    # Below - Ensures current user is not a guest.
    def is_logged_in?
      return true if current_user || current_admin
    end
    
    # Below - Checks if user is admin.
    def is_admin?
      return true if is_logged_in? && (current_user.admin? || current_admin)
    end

    # Below -  Checks if the resource is a Workplace Resource like WorkplacePost, SUggestion or Report
    def is_admin_resource?(resource) 
      resource_class = resource.class.to_s
      return true if resource_class == "WorkplacePost" || resource_class == "WorkplaceMapPost"  || resource_class == "LibraryUpload"
    end   
    
    # Below - Controller helper method version of view helper method to check is it's an admin page in workplaces. View version is in application_helper.rb file.
    def is_workplace_page? 
      return true if controller_name == "workplaces" || controller_name =="workplace_posts" || controller_name == "workplace_map_posts"
    end   
    
    # Below - Checks if current admin is super admin  
    def is_current_super_admin?
      if current_admin 
        if current_admin.super_admin?
          return true
        else 
          return false
        end 
      else 
        return false
      end 
    end   
# End - Helper methods for application with calls.
  
  private
    # Below - Pundit authorization error, displayed when exceptinos are thrown.
    rescue_from Pundit::NotAuthorizedError do 
      flash[:alert] = "You cannot perform that action."
      redirect_to(request.referrer || root_path)
    end
  
    # Below - called (once) when the user logs in, insert any code your application needs to hand off from guest_user to current_user.
 #   def logging_in
 #     guest_user.update(guest: false)
 #   end
    
    # Below - Create a guest user for DB. Will need to destroy this eventually.
  #  def create_guest_user
  #    u = User.new(:first_name => "Guest", :last_name => "User", :guest => true, :email => "guest_#{Time.now.to_i}#{rand(100)}@example.com", confirmed_at: Time.now, city_id: 0)
  #    u.save!(:validate => false)
  #    session[:user_id] = u.id
  #    return u
  #    # TODO: Create a delayed job here to destroy after a certain amount of time. 
  #  end


# Below, permits strong params from signup process, sign_in, and Account_update
  protected


end
