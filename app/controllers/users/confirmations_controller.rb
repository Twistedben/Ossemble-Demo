class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
   def new
     super
   end

  # POST /resource/confirmation
   def create
     super
   end

 
   private

  # The path used after resending confirmation instructions.
    def after_resending_confirmation_instructions_path_for(resource_name)
      user_path(current_user)
    end

  # The path used after confirmation.
    def after_confirmation_path_for(resource_name, resource)
      edit_user_registration_path(current_user)
    end

end
