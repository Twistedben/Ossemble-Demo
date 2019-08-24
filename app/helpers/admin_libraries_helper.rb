module AdminLibrariesHelper
# Main helper file for methods in Admin Libraries and used for _library_resources_list partial rendering.
  
  # Below - Returns the path to the index page of the library entry category
  def library_entry_category_link(city, admin, library, resource)
     resource_name = resource.class.to_s
     case resource_name 
     when "LibraryUpload"
      library_upload_path(city, admin, library, resource)
     else
       
     end 
  end
  
  def library_show_link(resource)
    
  end 
  
  # Below -  Displays resources description, but displays goal if a petition
  def display_library_entry_description(resource)
    resource_name = resource.class.to_s
    content_tag :a, :href => library_show_link(resource) do
      if resource.description.nil? 
        "No description has been provided for this upload."
      else 
        strip_tags(resource.description).truncate(225)
      end 
    end
  end   

  
end
