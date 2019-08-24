class LibraryUploadsController < AdminLibrariesController
# Main controller for uploading library files from personal library
  # Below - Makes sure admin is logged in
  before_action :authenticate_admin!
  # Below - Before action that sets upload via params
  before_action :set_upload, only: [:show, :edit, :update, :destroy]
  
  def index
    @uploads = @admin.uploads
  end 
  
  def show 
    @upload_comments = @upload.comments
  end 
  
  def new 
    @upload = LibraryUpload.new
    @admins = @institute.admins
    @institute_admins_path = new_library_upload_path(@institute, current_admin, current_admin.library)
  end 
  
  def create
    @admin = current_admin
    @upload = @admin.uploads.build(upload_params)
    @upload.admin_library_id = @library.id
    #authorize @upload # Ensures user owns the petition or is a mod
    if @upload.save # If it saves, display Flash message success, if not move to 'else'
      # Below - Adds to a users activity stream when creating a new Petition and assigns the city as the recipient of it.
      flash[:notice] = "Your #{@upload.title} has been uploaded successfully!"   # Shows a Flash message of success
      redirect_to library_upload_path(@institute, @admin, @library, @upload)  # Redirects to the Petition's show page.
    else
      flash[:alert] = "Could not save your Archive Upload. See why below!"   # Shows a Flash message of error
      render 'new' # Reload the New template with errors
    end # End - If statement for review creation.
  end 
  
  def edit 
    #authorize @upload # Ensures user owns the upload
    @admins = @institute.admins
    @institute_admins_path = new_library_upload_path(@institute, current_admin, current_admin.library)
  end 
  
  def update 
    #authorize @upload # Ensures user owns the petition or is a mod
    if @upload.update(upload_params)
      flash[:notice] = "Your #{@upload.title} Upload has been updated successfully!"
      redirect_to library_upload_path(@institute, @upload.admin, @library, @upload)
    else 
      flash[:alert] = "Your Archive Upload could not be updated. See why below!"
      render 'edit'
    end 
  end 
  
  def destroy 
    if @upload.admin == current_admin # Makes sure user deleting is user
      if @upload.destroy
        flash[:notice] = "Your Upload has been removed."
        redirect_to admin_library_uploads_path(@institute, @upload.admin, @library)
      else 
        flash[:alert] = "Your Upload could not be removed for some unknown reason. Please contact us."
        render 'edit'
      end
    end

  end 
  
  private 
  
  # Below -  Sets params for upload.
  def set_upload 
    @upload = LibraryUpload.friendly.find(params[:id])
  end   
  
  # Below -  Sets params for admin library id from inherited AdminLibraries class.
  def set_library
    @library = AdminLibrary.friendly.find(params[:admin_library_id])
  end   
  
  # Below -  Provides params for new library upload record.
  def upload_params 
     params.require(:library_upload).permit(:title, :description, :tags, :image, :file)
  end   
 
end
