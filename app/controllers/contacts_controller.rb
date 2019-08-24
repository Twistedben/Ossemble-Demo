class ContactsController < ApplicationController
# Main controller for creating Contact records for admins. 
  
  def create 
    @admin = current_admin
    @city = current_admin.institute
    @contact = @admin.contacts.build(contact_params)
    # Begin - If statement for determining if Contact was committed to the DB successfully, .
    if @contact.save # If it saves, display Flash message success, if not move to 'else'
      flash[:notice] = "You have successfully added contact information!"   # Shows a Flash message of success
      redirect_to request.referrer  # Redirects to the City Review's show page.
    else
      flash[:alert] = "Could not add this contact information. See why below!"   # Shows a Flash message of error
      redirect_to request.referrer # Reload with errors
    end 
  end 
  
  def edit 
    @contact = Contact.find(params[:id])
  
  end 
  
  def update 
    @admin = Admin.friendly.find(params[:admin_id])
    @contact = Contact.find(params[:id])
    if @contact.update(contact_params)
      flash[:notice] = "Your #{@contact.name} information has been updated successfully!"
      redirect_to request.referrer
    else 
      flash[:alert] = "Your #{@contact.name} information could not be updated. See why below!"
      redirect_to request.referrer
    end 

  end 
  
  def destroy 
    @contact = Contact.find(params[:id])
    if @contact.destroy
      flash[:notice] = "Your contact information has been deleted."
      redirect_to request.referrer
    else 
      flash[:alert] = "Your contact information could not be deleted for some unknown reason. Please contact us."
      redirect_to request.referrer
    end
  end 
  
  private 
  
  # Below -  Contact params for creation of Contact record
  def contact_params
     params.require(:contact).permit(:name, :information)
  end   
  
end 