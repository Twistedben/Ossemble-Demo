module FollowsHelper
# Main helper module with methods for acts_as_follower gem and actions.
 
 # Below -  Displays the follow button for the given resouce. Passed in is the follow route path, unfollow route path, and the resource itself. FIrst If statement checks if it's the user profile page (User Show).
  def display_follow_button(follow_link, unfollow_link, resource)
    if is_guest?
      # Dont show anything since they're guest
    else # user is not a guest
      case resource # Case statement, checking what the resource is, user for profile, subtopic for subtopics page, else for resources.
      # Begin - User Profile FOllow BUtton
        #DO nothing
      when @user # Method is being called from profile page, so checks is_current_user? for following.
        if current_user == resource || current_admin == resource
          # Shows nothing since it's the user's own profile. 
        elsif current_admin 
          # Do NOthing
        else # The user is not on their own profile
          if current_user.following?(resource)
            form_tag unfollow_link, method: :delete, remote: true do 
              button_tag "<i class='fas fa-angle-double-left margin-r-5'></i>Unfollow".html_safe, id: "unfollow_btn", class: 'btn btn-white margin-r-10'
            end 
          else 
            form_tag follow_link, method: :post, remote: true do 
              button_tag "<i class='fas fa-angle-double-right margin-r-5'></i>Follow".html_safe, id: "follow_btn", class: 'btn margin-r-10'
            end 
          end  # End of already following check
        end 
      # End - User Profile FOllow BUtton
      when @subtopic # Method is being called from Subtopic page
      # Begin - Subtopic FOllow Button
        if current_user.following?(resource)
          form_tag unfollow_link, method: :delete, remote: true do 
            button_tag "<i class='fas fa-angle-double-left margin-r-5'></i>Unfollow".html_safe, id: "unfollow_btn", class: 'btn btn-white'
          end 
        elsif current_admin 
          # Do NOthing
  
        else 
          form_tag follow_link, method: :post, remote: true do 
            button_tag "<i class='fas fa-angle-double-right margin-r-5'></i>Follow".html_safe, id: "follow_btn", class: 'btn'
          end 
        end  # End of already following check
      # End -Subtopic FOllow Button
      else # Method is not being called by profile page or subtopic. Reason this is separate is to check if user is owner of the resource.
      # Begin - Resource Follow Buttons (complaints, petitions, and posts). 
        if current_user && current_user == resource.user 
          # Shows nothing since it's the user's own profile. 
        elsif current_admin 
          # Do NOthing
          if is_admin_resource?(resource) 
            current_admin == resource.admin
          end        
        else # The user is not on their own profile
          if current_user.following?(resource)
            form_tag unfollow_link, method: :delete, remote: true do 
              button_tag "<i class='fas fa-angle-double-left margin-r-5'></i>Unfollow".html_safe, id: "unfollow_btn", class: 'btn btn-white'
            end 
          else 
            form_tag follow_link, method: :post, remote: true do 
              button_tag "<i class='fas fa-angle-double-right margin-r-5'></i>Follow".html_safe, id: "follow_btn", class: ' btn'
            end 
          end  # End of already following check
        end 
         # End - Resource Follow Buttons (complaints and posts). 
      end  # End - Type of resource case statement check
    end # End - Guest check
  end # End - Display_follow_button helper.
  # Below -  Displays followers count for given resource
  def display_follower_count(resource)
    follower_count = resource.followers_count 
    # Below - If statement determining plurality or singularity
    if follower_count == 0
      "No Followers"
    elsif follower_count == 1
      "#{follower_count} Follower"
    else
      "#{follower_count} Followers"
    end
  end   
  

end