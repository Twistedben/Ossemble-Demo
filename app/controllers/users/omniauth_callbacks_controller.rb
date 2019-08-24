class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
# Main Model for Facebook OmniAuth User Login/Signup

  def facebook
    #raise request.env["omniauth.auth"].to_yaml
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
      # Below - Shows first time login success for Facebook signup to FInish Profile Signup Process
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format? if @user.valid? 
      # Below - Shows different message for users who have not finished Profile Signup Process after Facebook Signup
      set_flash_message(:notice, :login, :kind => "Facebook") if is_navigational_format? if @user.valid? 
      # Below - Allows a facebook user to be subscribed to mailerlite. Setting facebook field to true.
      subscribe_to_mailerlite if Rails.env.production?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
    
  end

  def failure
    redirect_to new_user_registration_url
  end
  
  protected
  
    # Below -  Called in an after create action to subscribe the user
    def subscribe_to_mailerlite
      @user = current_user 
      info = { email: "#{@user.email}", name: "#{@user.first_name}", "fields": { last_name: "#{@user.last_name}", country: "US", city: "#{@user.city.name}", state: "#{@user.state}", zip: "#{@user.zip}", facebook: "True" } }
      MailerLite.create_group_subscriber(10144886, info)
    end   
  
end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  ##protected

  # The path used when OmniAuth fails
  #def after_omniauth_failure_path_for(scope)
    #super(scope)
  #end

