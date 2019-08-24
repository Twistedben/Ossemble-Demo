module WorkplacesHelper
  # Main helper methods for workplaces for admins
  
  # Below -  Returns the name of current workplace
  def current_workplace 
     return @workplace.name if @workplace
  end   
  
# Begin - RESOURCES: Helper methods for resource rendering in workplaces
  def display_workplace_image(resource)
    if resource.image.attached? # Since the resource has an uploaded attached image, it renders the image and a link to its show page.
      # Below - Checks the type of the resource to determine what link to render for the image and the show page with the method list_show_link
      link_to image_tag(resource.image.variant(combine_options: {crop: "1100x1100+0+0", gravity: "center"}), id: "list_image", class: "col-p-12 col-t-12"), workplace_show_link(resource)
    else 
      display_workplace_default_icon(resource, "list")
    end 
  end 
  
  # Below - Renders in the show link for the resource 
  def workplace_show_link(resource)
    resource_name = resource.class.to_s 
    case resource_name 
    when "WorkplacePost"
      workplace_post_path(resource.institute, resource.workplace, resource)
    when "WorkplaceMapPost"
      workplace_map_post_path(resource.institute, resource.workplace, resource)
    when "LibraryUpload"
      library_upload_path(resource.instituteresource.admin, resource.library, resource)
    else # Fail safe
      city_workplace_feed_path(resource.institute, resource.workplace)
    end # End - Resource check for different show pages. 
  end 
  
    # Below -  Displays the user's name and if they're a non-resident
  def display_workplace_user_name(resource)
    admin = resource.admin
    link_to "#{admin.name}", institute_admin_path(admin.institute, admin), id: "user_name", class: "" 
  end   
  
  # Below -  Displays default icon for show pages and to be invoked in display list image. Page argument determines what div id to render with, modifying css
  def display_workplace_default_icon(resource, page)
    resource_name = resource.class.to_s
    if page == "show" # Icon is being rendered from a show page so containing div has ID icon_container 
      content_tag :div, :id => "icon_container" do
        case resource_name
        when "WorkplacePost"
          "<i class='fas fa-comments'></i>".html_safe 
        when "WorkplaceMapPost"
          "<i class='fas fa-map-marked-alt'></i>".html_safe 
        when "LibraryUpload"
          "<i class='fas fa-paperclip'></i>".html_safe
        else 
          
        end # End - Resource check
      end # COntent do tag
    else # Icon is being rendered from list so containing div has ID default_icon_container 
      content_tag :div, :id => "default_icon_container" do
        case resource_name
        when "WorkplaceMapPost"
          if resource.category == "Suggestion"
            "<i class='fas fa-lightbulb'></i>".html_safe
          elsif resource.category == "Report"
           "<i class='fas fa-flag'></i>".html_safe
          else 
            "<i class='fas fa-map-marked-alt'></i>".html_safe 
          end
        when "WorkplacePost"
          "<i class='fas fa-comments'></i>".html_safe 
        when "LibraryUpload"
          if resource.image.attached?
            link_to image_tag(resource.image.variant(combine_options: {crop: "1100x1100+0+0", gravity: "center"}), id: "list_image", class: "col-p-12 col-t-12"), library_entry_category_link(resource.admin.institute, resource.admin, resource.library, resource)
          else   
            "<i class='fas fa-paperclip'></i>".html_safe
          end
        else 
          
        end # End - Resource check
      end # COntent do tag

    end 
  end   
 
# End - RESOURCES
  
    
  
end
