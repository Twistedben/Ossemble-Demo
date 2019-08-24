class WorkplacesController < ApplicationController
# Main controller for Workplaces in Admins sections.
  # Below - Makes sure admin is logged in and isn't a user
  before_action :authenticate_admin!
  # Below - Before action that sets city from params
  #before_action :set_city, only: [:show]
  # Below - Before action that sets institute from params
  before_action :set_institute
  # Below - Before action that
  before_action :set_workplace_id, only: [:invite_member, :signup_create_member, :signup_invite_member, :create_member, :invite_workplace_share_link, :workplace_departments, :create_departments, :destroy_department]
  # Below - Before action that sets the workplace from params
  before_action :set_workplace, only: [:show, :test_map, :after_signup_page, :workplace_map, :directory, :edit, :update, :finish_workplace_creation]
  # Below - Before action that ensures the page can only be visited by a super admin
  before_action :authenticate_super_admin, only: [:after_signup_page]
  # Below - Before action that makes sure user is allowed to access workplace based on if they belong to it
  append_before_action :authenticate_workplace_membership, except: [:county_map, :state_map, :congressional_map, :index, :destroy, :new, :create, :invite_existing_admin, :create_member, :create_departments, :destroy_department, :finish_workplace_creation, :after_signup_page]
  # Below - Checks (or renders flash or passes instance variable) if the institute/admin has paid access to certain page.
  before_action :check_subscription_plan, only: [:workplace_map]

  # Below - Renders flash and passes instance variable if the institute/admin has ability to invite more members. The actual denial happens in :create_member.
  before_action :check_user_count, only: [:invite_member]

  def index

  end

  def show
    if @workplace.activated == false
      flash[:alert] = "Please first assign a map location to this Channel."
      redirect_to new_workplace_shape_path(@institute, @workplace)
    else 
      @posts = @workplace.posts + @workplace.map_posts
    end 
  end

  def new
    # Below - Renders flash and passes instance variable if the institute/admin has ability to create more workplaces. The actual denial happens in creation (:create).
    check_workplace_count
    authenticate_super_admin
    @workplace = @institute.workplaces.build
    3.times { @workplace.workplace_departments.build }
  end

  def create
    @workplace = @institute.workplaces.build(workplace_department_params) 
    # Below - Throws an exception since there are more or the same workplaces as allowed by the subscription.
    if @institute.plan.workplace_count <= @institute.workplaces.count
      flash[:alert] = "Your Channel could not be created because your #{@institute.plan.name} Subscription plan permits #{@institute.plan.workplace_count} of them. Please upgrade your subscription!"
      # Below - Sends them to payments/subscription page to upgrade.
      redirect_to payments_path(@institute)
    elsif @workplace.save
      @workplace.create_welcome_post(current_admin) # Creates the welcome post in the new workplace from Workplace Model.
      # Below - Shuffles the admin into the newly created workplace
      @workplace.join_workplace(current_admin)
      flash[:notice] = "Your Channel, #{@workplace.name}, has successfully been created! Now, assign a Location to it."
      redirect_to new_workplace_shape_path(@institute, @workplace)
    else 
      flash[:alert] = "Your Channel could not be created. See why below!"
      # Below - FIXME: Currently a redirect instead of a render, as page will not load without errors when rendering, so this is a workaround
      redirect_to new_institute_workplace_path(@workplace)
    end 
  end

  def edit
    # Below - BAsic authorization to ensure super_admin is editing workplace
    authenticate_super_admin
    @department = WorkplaceDepartment.new
  end
  
  def update
    if @workplace.update(workplace_params)
      flash[:notice] = "#{@workplace.name} has been updated successfully!"
      redirect_to request.referrer
    else 
      flash[:alert] = "Your Workplace could not be updated. See why below!"
      render 'edit'
    end 
  end

  def destroy
  end
  
  def workplace_map 
    if @workplace.activated == false
      flash[:alert] = "Please first assign a map location to this Channel."
      redirect_to new_workplace_shape_path(@institute, @workplace)
    else 
      @workplace_map_resources = @workplace.map_posts
    end 
  end 
  
  def test_map 
    if Rails.env.production?
      redirect_to workplace_map_path(@institute, @workplace)
    else 
      @workplace_map_resources = @workplace.map_posts
      respond_to do |format|
        format.json {render file: "/workplaces/us_counties.json" }
        format.html
      end

    end 
  end 
   
  def workplace_departments 
    @department = WorkplaceDepartment.new 
  end 
  
  def create_departments 
    @department = @workplace.workplace_departments.build(department_params) 
    if @department.save
      flash[:notice] = "#{@department.name} Department has been created for #{@workplace.name}!"   # Shows a Flash message of success
      redirect_to request.referrer
    else 
      flash[:alert] = "Department could not be created. See why below!"   
      render 'workplace_departments'
    end 
  end 
  
  # Below - Allows removing of departments  
  def destroy_department
    @department = WorkplaceDepartment.find(params[:id])
    if @department.destroy
      flash[:notice] = "You've removed this department from #{@workplace.name}"
      redirect_to request.referrer
    else 
      flash[:alert] = "This department could not be removed for some reason. Please contact us for assistance."
      render 'workplace_departments'
    end 
  end   
  

  # Below -  Workplace directory page
  def directory 
     @workplace_members = @workplace.members
  end   
  
  # Below -  Bridge page for super admin to edit workplace and create departments.
  def after_signup_page
    if @workplace.activated? && Rails.env.production?
      flash[:notice] = "Workplace has already been setup."
      redirect_to workplace_feed_path(@institute, @workplace)
    else
      3.times { @workplace.workplace_departments.build }
    end 
  end   
  
  # Below -  Post - Commiting workplace update and department creation for after_signup_page. Runs once
  def finish_workplace_creation
    @workplace.activated = true
    if @workplace.update(workplace_department_params) 
      @workplace.create_welcome_post(current_admin) # Creates the welcome post in the new workplace from Workplace Model.
      flash[:notice] = "Your first Channel, #{@workplace.name}, has successfully been created! Now, invite co-workers and others to join."
      redirect_to new_workplace_invite_path(@institute, @workplace)
    else 
      flash[:alert] = "Your Channel could not finish. See why below!"
      render 'after_signup_page'
    end 
  end   
  
  # Below -  Invite member page
  def invite_member 
    @admins = @institute.admins
    3.times { @workplace.invites.build }
  end   
  
  # Below - POST for inviting member(s) to a workplace
  def create_member
    # Below - Throws an exception since there are more or the same users in institute than allowed in subscription 
    if @institute.plan.user_count <= @institute.admins.count 
      flash[:alert] = "You could not invite more Workplace members because your #{@institute.plan.name} Subscription plan permits #{@institute.plan.user_count} of them. Please upgrade your Subscription!"
      redirect_to payments_path(@institute)
    else
      @sender           = current_admin
      @invites          = params[:invite] 
      @invites.each do |invite| 
        invite_email      = invite[:email]
        invite_first_name = invite[:first_name]
        invite_last_name  = invite[:last_name]
        full_name         = "#{invite_first_name} #{invite_last_name}"
        workplace_id      = invite[:workplace_id]
        workplace         = Workplace.find(workplace_id)
        new_invite        = Invite.new(sender_id: @sender.id, email: invite_email, first_name: invite_first_name, last_name: invite_last_name, workplace_id: workplace_id )
        if new_invite.save 
        # Below - Sends email from views/admins/mailer/workplace_invite.html.erb and mailers/admin_mailer.rb
          if new_invite.recipient != nil 
            AdminMailer.existing_workplace_invite(@sender, new_invite, invite_email, full_name, workplace).deliver #send the invite data to our mailer to deliver the email
            new_invite.recipient.workplaces.push(workplace)
          else 
            AdminMailer.new_workplace_invite(@sender, new_invite, invite_email, full_name, workplace, new_invite.token, @workplace.id).deliver #send the invite data to our mailer to deliver the email
          end 
          flash[:notice] = "Channel invite has been sent! Feel free to send more."  
        else
        end     
      end 
      redirect_to request.referrer 
    end # Subscription check
  end   
  
  # Below -  Page admin is directed to after they first signup, create institute, and then sent to after creating workplace shape.
  def signup_invite_member 
    @admins = @institute.admins
    3.times { @workplace.invites.build }
  end  
    
  # Below - POST for inviting member(s) to a workplace after initial signup
  def signup_create_member
    @sender           = current_admin
    @invites          = params[:invite] 
    @invites.each do |invite| 
      invite_email      = invite[:email]
      invite_first_name = invite[:first_name]
      invite_last_name  = invite[:last_name]
      full_name         = "#{invite_first_name} #{invite_last_name}"
      workplace_id      = invite[:workplace_id]
      workplace         = Workplace.find(workplace_id)
      new_invite        = Invite.new(sender_id: @sender.id, email: invite_email, first_name: invite_first_name, last_name: invite_last_name, workplace_id: workplace_id )
      if new_invite.save 
      # Below - Sends email from views/admins/mailer/workplace_invite.html.erb and mailers/admin_mailer.rb
        if new_invite.recipient != nil 
          AdminMailer.existing_workplace_invite(@sender, new_invite, invite_email, full_name, workplace).deliver #send the invite data to our mailer to deliver the email
          new_invite.recipient.workplaces.push(workplace)
        else 
          AdminMailer.new_workplace_invite(@sender, new_invite, invite_email, full_name, workplace, new_invite.token, @workplace.id).deliver #send the invite data to our mailer to deliver the email
        end 
        flash[:notice] = "Channel invite has been sent. This is the Channel feed. You can navigate through the workplace and channels by using the side panel to the left, and can post by clicking the button above."
      else
      end     
    end 
    redirect_to workplace_feed_path(@institute, @workplace, after_signup: "true")
  end   
  
  # Below -  Allows a POST action to add an admin to a workplace on InviteMember page.
  def invite_existing_admin 
    @admin = Admin.friendly.find(params[:admin_id])
    @workplace = Workplace.friendly.find(params[:workplace_id])
    @institute = Institute.friendly.find(params[:institute_id])
    @workplace.join_workplace(@admin)
    @sender = current_admin
    @invite = "nil"
    AdminMailer.existing_workplace_invite(@sender, @invite, @admin.email, @admin.name, @workplace).deliver #send the invite data to our mailer to deliver the email
  end   
  
  # Below - POST action for creation of copied invite link into a workplace.
  def invite_workplace_share_link
    flash[:notice] = "Channel invite link successfully copied. This link can now be shared for others to join."
    redirect_to new_workplace_invite_path(@institute, @workplace)
  end 

  private 
  
  # Below -  Sets the city
  def set_city 
    @city      = City.friendly.find(params[:city_id])
  end   
  
  # Below -  Sets the city
  def set_institute
    @institute = Institute.friendly.find(params[:institute_id])
  end   
  
  # Below -  Sets the given workplace
  def set_workplace 
    @workplace = Workplace.friendly.find(params[:id])
  end   
  
  # Below -  Sets the actual :workplace_id for invite pages and departments
  def set_workplace_id
     @workplace = Workplace.friendly.find(params[:workplace_id])
  end   

  # Below - Whitelists params and attributes for inviting workplace members 
  def invite_params 
    params.require(:invite).permit(:id, :email, :first_name, :last_name, :workplace_id, :sender_id, :recipient_id, :_destroy)
  end   
  
  # Below - Whitelists params and attributes for inviting workplace members 
  def workplace_params 
    params.require(:workplace).permit(:name, :description, :public)
  end   
  
  # Below -  Whitelists params and attributes for workplace department creation.
  def department_params 
    params.require(:workplace_department).permit(:name, :description)
  end   
  
  # Below -  Whitelists params and attributes for workplace updating and department creation as nested attributes. Only called from finish_workplace_creation action.
  def workplace_department_params 
    params.require(:workplace).permit(:name, :description, :public, workplace_departments_attributes: [:id, :name, :description, :_destroy])
  end   
  
  # Below -  Ensures only a super admin can access the page
  def authenticate_super_admin 
    # Below - BAsic authorization to ensure super_admin is editing workplace
    unless current_admin.super_admin?
      flash[:alert] = "You don't have permission to access this page."
      redirect_to institute_admin_path(@institute, current_admin)
    end  
  end   
  
  # Below - Ensures admin belongs to workplace 
  def authenticate_workplace_membership 
    # UNless the current admin belongs to the workplace, send them to profile page with a flash message (admin.rb model method)
    unless current_admin.belongs_to_workplace?(@workplace)
      flash[:alert] = "You do not belong to this workplace. Contact #{@institute.super_admins.first.name} to request access to a workplace."
      redirect_to institute_admin_path(@institute, current_admin) 
    end 
  end   
  
  # Below -  Passes instance  variable and flash message for paid access to page. Unauthorized instance variable is checked in application.html.erb to render a flash message
  def check_subscription_plan
    if @institute.plan.extra_features == false
      @unauthorized = "true"
      @page_access = "true"
      @location = "Channel Map view"
    end 
  end   
  
  # Below - Checks if the admin can create another workplace according to their subscription plan.
  def check_workplace_count
    unless @institute.plan.unlimited_workplaces? 
      if @institute.plan.workplace_count <= @institute.workplaces.count
        @unauthorized = "true"
        @page_access = "false"
        if @institute.plan.workplace_count == 1
          @location = "#{@institute.plan.workplace_count} Workplace Channel"
        else 
          @location = "#{@institute.plan.workplace_count} Workplace Channels"
        end 
      end 
    end
  end

  # Below - Checks if the admin can Send out any more invites to the workplace according to their subscription plan.
  def check_user_count
    unless @institute.plan.unlimited_users? 
      if @institute.plan.user_count <= @institute.admins.count
        @unauthorized = "true"
        @page_access = "false"
        @location = "#{@institute.plan.user_count} Workplace Users/Members"
      end 
    end
  end

end
