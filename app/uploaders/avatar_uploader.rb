# Old carrierwave info 
=begin
class AvatarUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :amazon
  #process :resize_to_fill => [500, 500]
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
# Begin - Creation of different sized Avatar pictures for separate uses in website.
  # Below - Creates a Profile pic for User Show page and Update Profile Page.
  version :fff do
    process resize_to_fit: [150, 150]
  end
  # Below - Creates a navbar_pic for uploaded Avatar to display on logged in users' Navabar.
  version :navbar_pic do
    process resize_to_fit: [45, 45]
  end
  # Below - Creates a little larger uploaded Avatar for comments made by Users
  version :comment_pic do 
    process resize_to_fit: [75, 75]
  end 

# End  - Creation of different sized Avatar pictures for separate uses in website.

  # Below - we create an uploader variable to store different sizes of the pic upon the act of uploading
  #uploader = AvatarUploader.new
  #uploader.store!(:avatar)                              # size: 1024x768

  #uploader.url # => '/url/to/my_file.png'               # size: 800x800
  #uploader.thumb.url # => '/url/to/thumb_my_file.png'   # size: 200x200
  
  # Provide a default URL as a default if there hasn't been a file uploaded:
   def default_url(*args)
     # For Rails 3.1+ asset pipeline compatibility:
     ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  
     "/images/fallback/" + [version_name, "default.png"].compact.join('_')
   end

  # Process files as they are uploaded:
  #process scale: [300, 300]
  #
  #def scale(width, height)
  #  process resize_to_fit: [width, height]
  #end

 

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg jpeg png)
  end
  # Adding a whitelist for file formats of recognizable images
  def content_type_whitelist
    /image\//
  end
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
=end