class LocationsController < ApplicationController
# Controller for verifying the user and their address and zip code to work with Geocoder and geocodio. This will be used to create the location
  # association with the user trying to verify their profile. 
  # Below -  
  def new 
    @location = Location.new
  end   
  def create 
    @user = current_user
    @location = Location.new(location_params)
    @location.user_id = @user.id
    # Below - Verifies a user if they haven't yet been, and changes flash message based on if they've written a city review or not.
    if @location.save 
      if @user.verify_user # If the user goes through verification 
        if @user.filled_out_public? == false && @user.has_badge?("Pioneer") # If user hasn't filled out public info and is a pioneer
          flash[:notice] = "You have successfully verified your profile for #{@user.city.name} and have been awarded the Pioneer Badge! Be sure to fill out the Public Profile Details below as well."
          redirect_to request.referrer
        elsif @user.filled_out_public? == false # If user hasn't filled out public info
          flash[:notice] = "You have successfully verified your profile for #{@user.city.name}! Be sure to fill out the Public Profile Details below as well."
          redirect_to request.referrer
        else 
          flash[:notice] = "You have successfully verified your profile for #{@user.city.name}!"
          redirect_to user_path(@user)
        end 
      else 
        flash[:notice] = "You have successfully verified your profile for #{@user.city.name}!"
        redirect_to request.referrer
      end
    else 
      flash[:alert] = "Your address could not be verified."
      redirect_to request.referrer
    end
  end 

  private 
  
  # Below -  
  def location_params 
    params.require(:location).permit(:street, :street2, :zip_code)
  end   


end 