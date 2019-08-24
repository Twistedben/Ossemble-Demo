class ActivitiesController < ApplicationController
# Main controller for user activities. Inherits from the users controller.
  # Below - Before action that sets the user from params and city from user.
  before_action :set_user_and_city
  
  # Below - Lists all associated public activity by created at descending.
  def index
    @activities = PublicActivity::Activity.order("created_at desc").where(owner_id: @user.id, owner_type: "User")
  end
  
  private 
  
  # Below - finds user from params and city from user.
  def set_user_and_city
     @user = User.friendly.find(params[:user_id])
     @city = @user.city
  end   
  
end
