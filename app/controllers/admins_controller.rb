class AdminsController < ApplicationController
  before_action :authenticate_admin!, except: [:city_basic, :demo_admin_creation]
  # Below - Before action that sets admin from params and city.
  before_action :set_city_and_admin, except: [:city_basic, :settings, :index, :edit, :update, :demo_admin_creation, :destroy]
  # Below - Before action that runs on show to set up instance variables
  before_action :set_admin_settings_variables , only: [ :edit, :update, :destroy ]

  # GET /admins.json 
  def index 
    @admins = Admin.all
  end 
  
  def show 
    # Before Action ID sets for City and Admin ID
  end
  
  # GET  /:city_id/:admin_id/edit. Overrides the admins/registrations_controller, but update goes to admins/registrations_controller.rb
  def edit 
    @domain = current_admin.institute.split_email_domain
    @contact = Contact.new
    @city_user = @admin
  end 
  
  # Below - Page linked to an invited admin to quickly update their profile after signing up. 
  def after_signup_edit
    
  end   
  
  # Below - PATCH/PUT for updating the admin profile after they created their profile
  def finish_after_signup
    if @admin.update(finish_signup_update_params)
      flash[:notice] = "Profile creation completed! Welcome to your workplace feed. Start collaborating now by clicking Post!"
      redirect_to workplace_feed_path(@institute, @admin.workplaces.first)
    else 
      flash[:alert] = "Your profile could not finish. See why below!"
      render 'after_signup_edit'
    end 
  end   
  
  def profiles 
    
  end 
  
  def subscriptions 
     
  end 
  
  def departments 
    
  end 
  

  def petitions 
    
  end 
  
  def complaints 
   
  end 
  
  # Below - Special ink for cities and accelators and others to have a guest admin account created for them  
  def demo_admin_creation
    @institute = Institute.find_by_name("Ossemble Demo") 
    @workplace = @institute.main_workplace 
    guest_count = Admin.where(first_name: "Guest").count
    email = "guest.#{guest_count}@ossemble.com"
    @guest = Admin.new(email: email, password: "password", street: "Guest Lane", institute_id: 1, phone_number: "555-555-5555", state: "Ohio", zip_code: "44107", first_name: "Guest", last_name: "#{guest_count}", organization: "guest")
    if @guest.save 
      @guest.join_institute_workplace
      sign_in(:admin, @guest)
      flash[:notice] = "Welcome to Ossemble! We're glad you're here to try out our platform. This is a trial Workplace Channel so feel free to start posting content right away. Let us know if you have any questions by<a href='mailto:support@ossemble.com' class='title_link'>clicking here</a>"
      redirect_to workplace_feed_path(@institute, @workplace)
    else 
      flash[:alert] = "Could not create a demo guest account for some reason. Please contact us by<a href='mailto:support@ossemble.com' class='title_link'>clicking here</a>"
      redirect_to root_path
    end 
  end 

  private
  
  # Below - Sets instance variables for show page  
  def set_admin_settings_variables
    @institute = Institute.friendly.find(params[:institute_id])
    @admin = Admin.friendly.find(params[:id])
  end   
  
  # Below -  Sets admin and city from params URL
  def set_city_and_admin
    @institute = Institute.friendly.find(params[:institute_id])
    @admin = Admin.friendly.find(params[:admin_id])
  end   
  
  def account_update_params
    params.require(:admin).permit(:email, :zip_code, :first_name, :last_name, :phone_number, :institute_id, :password, :street, :street2, :state, :avatar, :title, :bio)
  end
  
  # Below - Params for finishing admin profile on after_signup page
  def finish_signup_update_params
    params.require(:admin).permit(:workplace_department_id, :avatar, :title, :resident_date, :bio)
  end
 
end