class Admins::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  # Below - Before action that sets admin only on edit page
  before_action :set_admin, only: [:edit]
  
  
  # GET /resource/sign_up
  def new
    @token = params[:invite_token] if params[:invite_token]
    @workplace_id = params[:workplace_id] if params[:workplace_id]
    @workplace = Workplace.find(params[:workplace_id]) if params[:workplace_id]
    @institute = @workplace.institute if @workplace
    # Below - Before action that checks institute's user count to subscription allowance and renders flash message if exceeded
    check_user_count if @workplace
    super
  end


  # POST Admin creation after signup
  def create
    build_resource(sign_up_params)
    # Below - If admin is coming from an email invite or shared invite link, grabs both token and workplace id from params.
    @token = params[:invite_token] if params[:invite_token]
    @workplace_id = params[:workplace_id] if params[:workplace_id]
    @workplace = Workplace.find(params[:workplace_id]) if params[:workplace_id] # Finds the workplace from the workplace_id, works for both invite email and shared link.
    @institute = @workplace.institute if params[:workplace_id]
    if @institute && @institute.has_super_admins?
      resource.super_admin = false
    end 
    
    if resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          # Below - If admin came from a shared workpalce invite link or email workplace invite
          if @token != nil # Admin signed up via a workplace invite email or the shared link
            # Below - Checks Payment plan for admins joining an institute to make sure the institute didn't exceed user count subscription permission.
            unless @institute.plan.unlimited_users? 
              if @institute.plan.user_count <= @institute.admins.count # Admin doesn't join workplace since institute has excited user allowance
                set_flash_message! :alert, :signed_up_no_workplace, :workplace => @workplace.name, :institute => @institute.name, :workplace_owner => @institute.subscription.admin.name
                sign_up(resource_name, resource)
                respond_with resource, location: institute_admin_path(resource.institute, resource)
              else # Admin successfully signs up and joins the workplace. Method is below in protected
                join_workplace_and_redirect
              end 
            else # Admin successfully signs up and joins the workplace. Method is below in protected
              join_workplace_and_redirect
            end
          else # Fresh admin signup
            sign_up(resource_name, resource)
            if resource.super_admin? # Checks if the admin is a super_admin and set as true, if so redirects to another page
              set_flash_message! :notice, :super_admin_signed_up, :name => resource.first_name
              respond_with resource, location: new_institute_path()
            else # Admin is not a super_admin and not first one who signed up inside a city. 
              set_flash_message! :notice, :admin_signed_up, :link => edit_institute_admin_path(resource.institute, resource), :city => resource.institute.name
              respond_with resource, location: after_sign_up_path_for(resource)
            end 
          end
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        flash[:alert] = "Your profile could not be created. See why below!"
        set_flash_message! :alert, :"signed_up_but_#{resource.inactive_message}"
        redirect_to request.referrer
      end
    else  # Failed to save
      clean_up_passwords resource
      respond_with resource, location: new_admin_registration_path(workplace: @workplace)
    end
  end
  

  # GET /resource/edit
  def edit
    @domain = current_admin.institute.split_email_domain
    @contact = Contact.new
    @city_user = @admin
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  protected
  
  # Below - Called above in creation of admin to join the workplace and redirect the user
  def join_workplace_and_redirect
    @workplace.join_workplace(resource)
    set_flash_message! :notice, :workplace_signup, :workplace => @workplace.name
    sign_up(resource_name, resource)
    respond_with resource, location: workplace_feed_path(resource.institute, @workplace, after_signup: true)
  end

  # Below -  Sets up the instance variables for admin registration pages and actions
  def set_admin
    @admin = current_admin
  end   

  # Below - Strong params for creating new admin profile.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:password, :super_admin, :phone_number, :email, :institute_id, :first_name, :last_name, :organization, :street, :visitor])
  end

  # Below - Strong params for editing admin profile.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :organization, :zip_code, :first_name, :last_name, :phone_number, :password, :street, :street2, :state, :avatar, :title, :bio])
  end

  # Redirects to the path used after admin sign up.
  def after_sign_up_path_for(resource)
    workplace_feed_path(resource.institute, resource.main_workplace)
  end
  # Redirects to the path used after admin confirms their account via email.
  def after_confirmation_path_for(resource)
    workplace_feed_path(resource.institute, resource.main_workplace)
  end
  # Redirects to the path used after admin update.
  def after_update_path_for(resource)
    edit_admin_path(current_admin.institute, current_admin)
  end
  # Below - Allows views/admins/registrations/edit.html.erb update the account without current_password
  def update_resource(resource, params)
    resource.update_without_password(params)
  end
  # Below - Checks if the admin can Send out any more invites to the workplace according to their subscription plan.
  def check_user_count
    unless @institute.plan.unlimited_users? 
      if @institute.plan.user_count <= @institute.admins.count
        @unauthorized = "true"
        @new_user = "true"
        @page_access = "false"
        @location = "#{@institute.plan.user_count} Workplace Users/Members"
        @contact = "Please contact #{@institute.subscription.admin.name} in order to upgrade the subscription and lift or remove this restriction."
      end 
    end
  end

end
