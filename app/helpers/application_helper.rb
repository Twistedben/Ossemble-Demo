module ApplicationHelper
  # Below - For Flash Messages inside views/layouts/_messages.html.erb)
  def bootstrap_class_for flash_type
    case flash_type
    when :success 
      "alert-success"
    when :warning
      "alert-warning"
    else
      flash_type.to_s
    end
  end
  # Below - Displays the owl favicon for community score image.
  def display_cs_owl
    image_tag 'logos/Owl_FavIcon.png', class: "mr-1 mb-0 pl-0 border-none padding-t-0 margin-t-5 no-border", id: "brand_ossemble", style: "height: 65px; width: 65px;" 
  end   

  # Below Displays month and day date resource being like @user.created_at
  def display_date(resource)
     resource.to_date.to_formatted_s(:long_ordinal)
  end
  
  # Below - Returns the date of a resource in numbered format like 01/31/18
  def display_date_in_numbers(resource) 
     resource.strftime("%m/%d/%y")
  end   
  
  # Below - Displays comment count with the passed in resource and pluralization or singularization or "No Comments".
  def display_comment_count(resource)
    comment_count = resource.count_comments 
    if comment_count == 0
      "<i class='fas fa-comment margin-r-5'></i>No Comments".html_safe
    elsif comment_count == 1
      "<i class='fas fa-comment margin-r-5'></i>#{comment_count} Comment".html_safe
    else 
      "<i class='fas fa-comment margin-r-5'></i>#{comment_count} Comments".html_safe
    end
  end
  # Below -  Displays number of votes for a resource, changes if it's a petition.
  def display_vote_count(resource)
    vote_count = resource.votes_for.count
    if resource.class.to_s == "Petition" # Resource is a petition so Signatures term is used.
      if vote_count == 0
        "<i class='fas fa-file-signature margin-r-5'></i>No Signatures".html_safe
      elsif vote_count == 1
        "<i class='fas fa-file-signature margin-r-5'></i>#{vote_count} Signature".html_safe
      else 
        "<i class='fas fa-file-signature margin-r-5'></i>#{vote_count} Signatures".html_safe
      end 
    else # Resource is not displaying votes for a petition, so Endorsements term is used.
      if vote_count == 0
        "<i class='fas fa-arrow-circle-up margin-r-5'></i>No Upvotes".html_safe
      elsif vote_count == 1
        "<i class='fas fa-arrow-alt-circle-up margin-r-5'></i>#{vote_count} Upvote".html_safe
      else 
        "<i class='fas fa-arrow-alt-circle-up margin-r-5'></i>#{vote_count} Upvotes".html_safe
      end 
    end 
  end   
  # Below -  Displays score of resource with percentage 
  def display_score(resource)
     "#{resource.score.to_i.to_s}%"
  end   
  # Below - Checks if user voted or admin for given passed in argument.
  def user_voted_for?(resource)
    if current_admin && is_admin_resource?(resource)
      return true if current_admin.voted_for? resource
    else 
    end 
  end
  # Below - Checks if current user owns given object for given passed in argument. Also checks for admin
  def is_current_users?(resource)
    if current_admin && is_admin_resource?(resource)
      return true if resource.admin == current_admin
    else 
      return true if resource.user == current_user
    end 
  end
  # Below - Checks the current page using the passed in controller and action in arguments.
  def is_current_page?(controller, action)
    return true if current_page?(controller: "#{controller}", action: "#{action}")
  end
  # Below - Ensures current page is not splash landing page.
  def is_not_landing_page?
    return true if current_page?(controller: 'visitors', action: 'index') == false
  end 
  # Below - Ensures current page is non-city related pages, like about, users, and landing pages.
  def is_guest_page?
    return true if controller_name == "institutes" || controller_name == "workplace_shapes" || current_page?('/') || current_page?('/users/login') || current_page?(controller: 'sessions', action: 'create') || controller_name =="admins" || controller_name == 'sessions'  || controller_name == 'visitors' || controller_name == 'registrations' || current_page?('/users/sign_up') || current_page?('/about') || current_page?('/about/inspiration') || current_page?('/about/team') || current_page?('/about/city_score') || current_page?('/about/policies') || current_page?('/about/city')  || current_page?('/contact_us') || current_page?('/love') || current_page?('/about/city_forum') || current_page?('/love') || current_page?('/about/reputation') || current_page?('/workplace/login') || current_page?('/workplace/sign_up')
  end   
  # Below -  Checks if the page is currently a workplace page with a defined @workplace instance variable
  def is_workplace_page? 
    if controller_name == "workplaces" || controller_name =="workplace_posts" || controller_name == "workplace_map_posts" 
      unless current_page?(new_city_workplace_path(@institute)) || current_page?(city_workplaces_path(@institute)) 
        return true 
      else 
        return false
      end 
    else 
      return false
    end 
  end  
  # Below -  Checks if the page is one of the workplaces pages without @workplace properly defined because it's an index or new or create workplace page
  def is_undefined_workplace_page? 
    if controller_name == "workplaces"
      return true if current_page?(new_institute_workplace_path(@institute)) || current_page?(institute_workplaces_path(@institute)) 
    else 
      return false
    end 
  end   
  # Below - Checks if the page is currently on the chatroom
  def is_chatroom_page? 
    return true if controller_name == "admin_chatrooms" || controller_name == "admin_messages"
  end 
  # Below - Checks if the admin is currently in a library page
  def is_library_page? 
    return true if controller_name == "admin_libraries" || controller_name == "library_uploads" || controller_name == "library_entries"
  end   
  # Below - Checks if user is current user.
  def is_current_user?(user)
    return true if user == current_user 
  end   
  # Below -  Checks if current admin is admin 
  def is_current_admin?(admin)
    if current_admin
      return true if admin == current_admin 
    else 
      return false 
    end 
  end   
  # Below -  Checks if city public resource belongs to current admin 
  def is_current_admins?(resource)
    if current_admin
      return true if resource.user == current_admin
    else 
      return false
    end 
  end   
  # Below -  Checks if the resource belongs to an admin.
  def is_admins?(resource)
    return true if resource.user.admin?
  end   
  # Below -Displays whether score has decreased or increased with arrow and number of change for admins (city_dashboard_action_panel)
  def display_admin_city_score_change(city)
    if city.institute_score.score_increase? == true 
      "<i class='material-icons margin-x-5 text-success text-28'>trending_up</i> <span class='text-success'>#{city.institute_score.institute_score_change.round(2)}%</span>".html_safe
    else
      "<i class='material-icons margin-x-5 text-danger text-28'>trending_down</i> <span class='text-danger'>#{city.institute_score.institute_score_change.round(2)}%</span>".html_safe 
    end 
  end   
  # Below -Displays whether score has decreased or increased with just arrow for users, outside of admin dashboard (action_panel)
  def display_city_score_change(city)
    if city.institute_score.score_increase? == true 
      "<i class='material-icons margin-x-5 text-success text-35'>trending_up</i>".html_safe
    else
      "<i class='material-icons margin-x-5 text-danger text-35'>trending_down</i>".html_safe 
    end 
  end   
  # Below -  displayed City score with passed in city
  def display_city_score(city)
    city.institute_score.score.to_i.to_s
  end   
 
end
  
 
