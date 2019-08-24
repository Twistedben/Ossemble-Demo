class UsersController < ApplicationController
# Main Users Controller for Ossemble
  # Below - Before action that ensures user signup is finished after going through Facebook.
  before_action :user_signup_finished?, only: []
  # Below - Passes strong params during a user update.
  before_action :configure_account_update_params, only: [:update]
  # Below - Before action that
  before_action :set_user, only: [:people, :content, :topic, :reputation]
  # Show Action for individual user ID. 
  # Instead of setting Params old way, we use FriendlyID to find user by adding ".friendly" method.
  def show 
    @user = User.friendly.find(params[:id])  
    @city = City.friendly.find(params[:city_id])
    @conversation = Mailboxer::Conversation.new
    if @user.admin? 
      redirect_to city_basic_profile_path(@city, @user)
    else  
      @user_reviews = @user.department_reviews
      @user_wul = @user.city_review
      @user_comments = @user.comments
      @ownership = @user.ownership
      @persistence = @user.persistence 
      @communication = @user.communication
      @gratitude = @user.gratitude
      @user_votes = ActsAsVotable::Vote.where(voter_id: @user.id)
    end 
  end 
  
  def city_basic
    @city_user = User.friendly.find(params[:user_id])
    @city = City.friendly.find(params[:city_id])
    if current_admin
      if current_admin.city_user == @user
        @city = current_admin.city
        @admin = current_admin
        @city_user = current_admin.city_user 
      end
    else 
      
    end 
  end

  
  def edit
    super
  end  
  
  def update
    super
  end
  # Below -  Page that loads follows people via AJAX
  def people
    @people = @user.followings
    respond_to do |format|
      format.js 
    end 
  end 
  # Below -  Page that loads follows content via AJAX
  def content
    respond_to do |format|
      format.js 
    end 
  end
  # Below -  Page that loads follows topics via AJAX
  def topic 
    respond_to do |format|
      format.js 
    end 
  end   
  # Below -  Page that loads follows topics via AJAX
  def reputation 
    respond_to do |format|
      format.js 
    end 
  end  
  
  private
  
  def set_user
    @user = User.friendly.find(params[:id])
  end
  
  # Below - Checks if User has all Attributes valid and entered directing to show or edit_registration
  def user_signup_finished?
    unless is_guest?
      if current_user == User.friendly.find(params[:id])
        @user = current_user
        if @user.valid? == false    # If user's attributes are missing, sends them to 'Finish Profile Page'
          flash[:alert] = "Please finish signing up for Ossemble by entering your First Name, Last Name, Birth Date, Address, and ensuring your location is correct."
          redirect_to edit_user_registration_path # Finish Profile Page Setup with form
        end
      end
    end
  end 
  
  def set_user 
    @user = User.friendly.find(params[:id])
  end
  
  def set_city    
    # Below - Assigns lakewood to guest user unless their is a city in URL.
    @city = City.find(1) if is_guest? unless params[:city_id]
    # Below - Assigns @city as the user's city unless they're in a city.
    @city = current_or_guest_user.city if is_logged_in? unless params[:city_id]
    # Below - Assigns lakewood to guest user 
    @city = City.find(params[:city_id]) if params[:city_id]
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :gender, :dob, :phone_number, :address, :address2, :title, :resident_date, :bio, :state, :zip, :city_id, :uid, :avatar, :image])
  end

end
