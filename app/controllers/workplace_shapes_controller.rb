class WorkplaceShapesController < ApplicationController
# Main controller for workplace shapes 
  # Below - Makes sure admin is logged in and isn't a user
  before_action :authenticate_admin!
  # Below - Before action that sets both institute and workplace in full id
  before_action :set_institute_workplace
  # Below - Before action that makes sure user is allowed to access workplace based on if they belong to it
  append_before_action :authenticate_workplace_membership, only: [:new]

  
  def new 
    @shape = WorkplaceShape.new 
    if params[:map] == "county"
      county_json
    elsif params[:map] == "district"
      district_json
    end
  
  end 
  
  def create 
    @shape = WorkplaceShape.new(shape_params)
    @shape.workplace_id = @workplace.id
    if @shape.save
      @workplace.activate_workplace
      # Below - Redirects to new invite path if workplace is main since it's a fresh signup.
      if @workplace.is_main?
        @workplace.create_welcome_post(current_admin) # Creates the welcome post in the new workplace from Workplace Model.
        flash[:notice] = "Your first Channel, #{@workplace.name}, has successfully been created! Now, invite co-workers and others to join by sending emails or sharing the Invite Link."
        redirect_to signup_create_workplace_invite_path(@institute, @workplace)
      else 
        flash[:notice] = "Channel location has successfully been added! Welcome to your new channel, #{@workplace.name}. Invite members below from other channels or send out invites."
        redirect_to new_workplace_invite_path(@institute, @workplace)
      end 
    else 
      flash[:alert] = "There was a problem with assigning a location. See why below!"
      render 'new'
    end 
  end 
  
  def city_map 
    @area = "city"
    redirect_to new_workplace_shape_path(@institute, @workplace, map: @area)
  end 
  
  def county_map
    @area = "county"
    redirect_to new_workplace_shape_path(@institute, @workplace, map: @area)
  end 

  # Below -  Renders us_counties json for goe on workplace shape new
  def county_json
    respond_to do |format|
      format.json {render file: "/workplace_shapes/us_counties.json" }
      format.html
    end
  end   
  
  def district_map 
    @area = "district"
    redirect_to new_workplace_shape_path(@institute, @workplace, map: @area)
  end 
  
  def custom_map 
    @area = "custom"
    redirect_to new_workplace_shape_path(@institute, @workplace, map: @area)
  end 
  
  # Below -  Renders us_districts json for goe on workplace shape new
  def district_json
    respond_to do |format|
      format.json {render file: "/workplace_shapes/us_districts.json" }
      format.html
    end   
  end   
  
  protected 
  
  def set_institute_workplace
    @institute = Institute.friendly.find(params[:institute_id])
    @workplace = Workplace.friendly.find(params[:workplace_id])
  end 
  
  # Below -  Passes in params
  def shape_params 
    params.require(:workplace_shape).permit(:name, :category, :state_id, :geo, :geo_id)
  end   
  
  # Below - Ensures admin belongs to workplace 
  def authenticate_workplace_membership 
    # UNless the current admin belongs to the workplace, send them to profile page with a flash message (admin.rb model method)
    unless current_admin.belongs_to_workplace?(@workplace)
      flash[:alert] = "You do not belong to this workplace. Contact #{@institute.super_admins.first.name} to request access to a workplace."
      redirect_to institute_admin_path(@institute, current_admin) 
    end 
  end   

  
end
