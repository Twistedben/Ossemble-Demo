module UsersHelper
# Main Helper for Users 
# Begin - Helpers for Users/show.html.erb.  
 
  # Begin -  Helper methods for User show page concerning the Follows tab
   # Below -  
   def display_follow_content_link(resource) 
      case resource.class.to_s
      when "Complaint"
        link_to "<i class='fas fa-map-marker margin-r-10'></i>#{resource.title}".html_safe, city_complaint_path(resource.instituteresource), id: " " , class: " "
      when "Petition"
        link_to "<i class='fas fa-clipboard margin-r-10'></i>#{resource.title}".html_safe, city_petition_path(resource.instituteresource), id: " " , class: " "
      when "Post"
        link_to "<i class='fas fa-comment margin-r-10'></i>#{resource.title}".html_safe, subtopic_post_path(resource.instituteresource.topic, resource.subtopic, resource), id: " " , class: " "
      when "Subtopic"
        link_to "<i class='fas fa-comments margin-r-10'></i>#{resource.name}".html_safe, subtopic_path(resource.instituteresource.topic, resource), id: " " , class: " "
      else 
        # Failsafe
      end 
   end   
   
   # Below -  Displays unfollow button on user profile if the user is visiting their own profile for Complaints, Posts, Subtopics, and Petitions
   def display_unfollow_content(content)
      case content.class.to_s
      when "Complaint"
        form_tag complaint_unfollow_path(content.id), method: :delete, onclick: "$(this).hide();", data: {confirm: "You've unfollowed this complaint."}, remote: true do 
          button_tag "<i class='fas fa-angle-double-left margin-r-5'></i>Unfollow".html_safe, id: "follow_unfollow", class: 'btn btn-white'
        end 
      when "Petition"
        form_tag petition_unfollow_path(content.id), method: :delete, onclick: "$(this).hide();", data: {confirm: "You've unfollowed this petition."}, remote: true do 
          button_tag "<i class='fas fa-angle-double-left margin-r-5'></i>Unfollow".html_safe, id: "follow_unfollow", class: 'btn btn-white'
        end 
      when "Post"
        form_tag post_unfollow_path(content.id), method: :delete, onclick: "$(this).hide();", data: {confirm: "You've unfollowed this post."}, remote: true do 
          button_tag "<i class='fas fa-angle-double-left margin-r-5'></i>Unfollow".html_safe, id: "follow_unfollow", class: 'btn btn-white'
        end 
      when "Subtopic"
        form_tag subtopic_unfollow_path(content.id), method: :delete, onclick: "$(this).hide();", data: {confirm: "You've unfollowed this subtopic."}, remote: true do 
          button_tag "<i class='fas fa-angle-double-left margin-r-5'></i>Unfollow".html_safe, id: "follow_unfollow",  class: 'btn btn-white'
        end 
      else 
        # Failsafe 
      end 
   end   
  # End - Helper methods for User show page concerning the Follows tab
  
  # Below -  Displays the resources' owner, the user who posted it.
  def display_user_name(user) 
    if user.is_resident_of?(@city)
      link_to "#{user.name}", user_path(user.institute, user), id: "", class: "text-big" 
    else
      link_to "#{user.name} - <i class='text-15'>Non-Resident</i>".html_safe, user_path(user.institute, user), id: "", class: "text-big", title: "#{user.first_name} is from #{user.institute.name}, #{user.state}" 
    end 
  end   
  
  # Below - Displays edit for user on show pages 
  def display_edit_link(resource, link)
    if is_current_users?(resource)
      link_to "<i class='theme_color_dark fas fa-pencil-alt'></i> Edit".html_safe, link, class: "title_link text-xmedium"
    end 
  end   
# End - Helpers for Users/show.html.erb.  
  
end
