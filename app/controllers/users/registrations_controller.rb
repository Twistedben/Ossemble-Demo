class Users::RegistrationsController < Devise::RegistrationsController
   before_action :configure_sign_up_params, only: [:create]
   before_action :configure_account_update_params, only: [:update]
   after_action :subscribe_to_mailerlite, only: [:create]

  def new
    @dob_year = Time.now.year - 16
    @dob_month = Time.now.month
    @dob_day = Time.now.day
    super
  end

  # Below - Creates user profile,. but if they come from a page in which guest clicked endorse button, will return them to that page.
  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      # Assigns the city's zip code to a user if there is only one zipcode in the city. Otherwise will 
      resource.zip_code = resource.institute.zip_code if resource.institute.zip_codes.size == 1
      resource.state    = resource.institute.state_name 
      resource.confirm # Overrides confirmation for now.
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up, :link => edit_user_registration_path(resource)
        sign_up(resource_name, resource)
        sign_in(resource_name, resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  
  end
  
  # GET /resource/edit
   def edit
    @content_to_follow = current_user.city.subtopics.limit(6)
    @location = Location.new
    super
     
   end  
   
   # PATCH /resource/edit
  def update
    super   
  end
  
  
  protected
      # Below -  Called in an after create action to subscribe the user only in production.
    def subscribe_to_mailerlite
      @user = current_user
      if Rails.env.production?
        info = { email: "#{@user.email}", name: "#{@user.first_name}", "fields": { last_name: "#{@user.last_name}", country: "US", city: "#{@user.city.name}", state: "#{@user.city.state.name}", facebook: "False"}}
        MailerLite.create_group_subscriber(10144886, info)
      end
    end   
  
  # Below - Method that redirects a user  after updating to respective pages.
  def after_update_path_for(resource)
    if current_user 
      edit_user_registration_path(current_user)
    elsif current_admin
      edit_admin_registration_path(current_admin.institute, current_admin)
    end 
  end  

  # Below - Allows views/devise/registrations/edit.html.erb update the account without current_password
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :gender, :dob, :state, :city_id, :uid, :provider, :image, :avatar, :name])
  end
  
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :gender, :dob, :phone_number, :address, :address2, :state, :zip, :city_id, :avatar, :title, :verified, :resident_date, :neighborhood, :bio])
  end
end  

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.



  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

