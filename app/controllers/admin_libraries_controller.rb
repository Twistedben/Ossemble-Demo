class AdminLibrariesController < ApplicationController
  # Below - Before action that sets @admin from params
  before_action :set_admin_institute, except: [:remove_entry]
  # Below - Before action that
  before_action :set_library, except: [:remove_entry]
 
  def index
  end

  def show
    
  end
  
  def library_posts
    @entries = @library.entries.posts
    render action: :show
  end 
  
  def library_maps
    @entries = @library.entries.maps
    render action: :show
  end 
  
  def library_uploads
    @entries = @library.uploads
    render action: :show
  end 
  
  def library_upload_shares
    @entries = @library.entries.uploads
    render action: :show
  end 
  
  def library_post_shares
    @entries = @library.entries.shared_posts
    render action: :show
  end 
  
   # Below -  Removes Library Entry.
  def remove_entry 
    @library = AdminLibrary.friendly.find(params[:admin_library_id])
    @entry = LibraryEntry.find(params[:id])
    if @entry.destroy 
      flash[:notice] = "#{@entry.entriable.title} was removed from your Archive!"
      redirect_to request.referrer
    else 
      flash[:alert] = "Could not remove this from your Archive for some reason. Please contact us."
      redirect_to request.referrer
    end 
  end   

  
  private 
  
  # Below - Sets admin from a before action 
  def set_admin_institute
     @admin = Admin.friendly.find(params[:admin_id])
     @institute = Institute.friendly.find(params[:institute_id])
  end   
  
  # Below - Sets library  params 
  def set_library
    @library = AdminLibrary.friendly.find(params[:id])     
  end   

  
end
