module FilterPanelsHelper
  
  # Below - Returns link for filter panel with the icon and title for complaints categories and process
  def filter_panel_link(title, icon, page)
    case page
    when "com_index"
      link_to "#{icon} #{title}".html_safe, city_complaints_path(@city), class: "dropdown-item "
    when "verifying"
      link_to "#{icon} #{title}".html_safe, verifying_city_complaints_path(@city), class: "dropdown-item "
    when "pending"
      link_to "#{icon} #{title}".html_safe, pending_city_complaints_path(@city), class: "dropdown-item "
    when "filed"
      link_to "#{icon} #{title}".html_safe, filed_city_complaints_path(@city), class: "dropdown-item "      
    when "finished"
      link_to "#{icon} #{title}".html_safe, finished_city_complaints_path(@city), class: "dropdown-item "
    when "other"
      link_to "#{icon} #{title}".html_safe, other_city_complaints_path(@city), class: "dropdown-item "
    when "roadkill"
      link_to "#{icon} #{title}".html_safe, roadkill_city_complaints_path(@city), class: "dropdown-item "
    when "obstruction"
      link_to "#{icon} #{title}".html_safe, obstruction_city_complaints_path(@city), class: "dropdown-item "
    when "lights"
      link_to "#{icon} #{title}".html_safe, lights_city_complaints_path(@city), class: "dropdown-item "
    when "snow"
      link_to "#{icon} #{title}".html_safe, snow_city_complaints_path(@city), class: "dropdown-item "
    when "weeds"
      link_to "#{icon} #{title}".html_safe, weeds_city_complaints_path(@city), class: "dropdown-item "
    when "trash"
      link_to "#{icon} #{title}".html_safe, trash_city_complaints_path(@city), class: "dropdown-item "
    when "graffiti"
      link_to "#{icon} #{title}".html_safe, graffiti_city_complaints_path(@city), class: "dropdown-item "
    when "property"
      link_to "#{icon} #{title}".html_safe, property_city_complaints_path(@city), class: "dropdown-item "
    when "sidewalk"
      link_to "#{icon} #{title}".html_safe, sidewalk_city_complaints_path(@city), class: "dropdown-item "
    when "forestry"
      link_to "#{icon} #{title}".html_safe, forestry_city_complaints_path(@city), class: "dropdown-item "
    when "potholes"
      link_to "#{icon} #{title}".html_safe, potholes_city_complaints_path(@city), class: "dropdown-item "
    when "water"
      link_to "#{icon} #{title}".html_safe, water_city_complaints_path(@city), class: "dropdown-item "
    when "dep_index"
      link_to "#{icon} #{title}".html_safe, city_department_reviews_path(@city), class: "dropdown-item "
    when "government"
      link_to "#{icon} #{title}".html_safe, government_city_department_reviews_path(@city), class: "dropdown-item "
    when "schools"
      link_to "#{icon} #{title}".html_safe, schools_city_department_reviews_path(@city), class: "dropdown-item "
    when "parks"
      link_to "#{icon} #{title}".html_safe, parks_city_department_reviews_path(@city), class: "dropdown-item "
    when "police"
      link_to "#{icon} #{title}".html_safe, police_city_department_reviews_path(@city), class: "dropdown-item "
    when "public_works"
      link_to "#{icon} #{title}".html_safe, public_works_city_department_reviews_path(@city), class: "dropdown-item "
    when "cr_index"
      link_to "#{icon} #{title}".html_safe, city_review_index_path(@city), class: "dropdown-item "
    when "cr_loves"
      link_to "#{icon} #{title}".html_safe, loves_city_review_index_path(@city), class: "dropdown-item "
    when "cr_improves"
      link_to "#{icon} #{title}".html_safe, improves_city_review_index_path(@city), class: "dropdown-item "
    when "topics"
      link_to "#{icon} #{title}".html_safe, city_topic_path(@city), class: "dropdown-item "
    when "subtopics"
      link_to "#{icon} #{title}".html_safe, subtopic_path(@city), class: "dropdown-item "
    when "pet_index"
      link_to "#{icon} #{title}".html_safe, city_petitions_path(@city), class: "dropdown-item "
    when "pet_pending"
      link_to "#{icon} #{title}".html_safe, pending_city_petitions_path(@city), class: "dropdown-item "
    when "pet_filed"
      link_to "#{icon} #{title}".html_safe, filed_city_petitions_path(@city), class: "dropdown-item "
    end
  end
  
  # Below -  Displays main_filter_btn button label with icon when in subtopic path based on what subtopic's topic is.
  def display_topic_filter_title
    if current_page?(subtopic_path(@city, @lets_talk, @help_out)) || current_page?(subtopic_path(@city, @lets_talk, @business_buzz)) || current_page?(subtopic_path(@city, @lets_talk, @grinds_gears)) || current_page?(subtopic_path(@city, @lets_talk, @sports))
      return "<i class='fas fa-bullhorn'></i> Let's Talk".html_safe
    elsif current_page?(subtopic_path(@city, @city_affairs, @ballots)) || current_page?(subtopic_path(@city, @city_affairs, @city_improvements)) || current_page?(subtopic_path(@city, @city_affairs, @events)) || current_page?(subtopic_path(@city, @city_affairs, @schools))
      return "<i class='fas fa-gavel'></i> City Affairs".html_safe
    elsif current_page?(subtopic_path(@city, @good_vibes, @good_news)) || current_page?(subtopic_path(@city, @good_vibes, @city_snaps)) || current_page?(subtopic_path(@city, @good_vibes, @furry_friends)) || current_page?(subtopic_path(@city, @good_vibes, @local_historian))
      return "<i class='fas fa-hand-peace'></i> Good Vibes".html_safe
    else
    end
  end
  
  # Below -  For dropdown header in subtopics path, displays the title of the subtopic based on the topic the user is in.
  def display_subtopic_dropdown_header
    if current_page?(subtopic_path(@city, @lets_talk, @help_out)) || current_page?(subtopic_path(@city, @lets_talk, @business_buzz)) || current_page?(subtopic_path(@city, @lets_talk, @grinds_gears)) || current_page?(subtopic_path(@city, @lets_talk, @sports))
      return "Let's Talk".html_safe
    elsif current_page?(subtopic_path(@city, @city_affairs, @ballots)) || current_page?(subtopic_path(@city, @city_affairs, @city_improvements)) || current_page?(subtopic_path(@city, @city_affairs, @events)) || current_page?(subtopic_path(@city, @city_affairs, @schools))
      return "City Affairs".html_safe
    elsif current_page?(subtopic_path(@city, @good_vibes, @good_news)) || current_page?(subtopic_path(@city, @good_vibes, @city_snaps)) || current_page?(subtopic_path(@city, @good_vibes, @furry_friends)) || current_page?(subtopic_path(@city, @good_vibes, @local_historian))
      return "Good Vibes".html_safe
    else
    end
  end   
  
  # Below -  For dropdown header in subtopics path, displays the title of the subtopic based on the topic the user is in.
  def display_subtopic_button_title
    if current_page?(subtopic_path(@city, @lets_talk, @help_out)) 
      return "<i class='fas fa-handshake'></i>Help Me Out".html_safe
    elsif current_page?(subtopic_path(@city, @lets_talk, @business_buzz)) 
      return "<i class='fas fa-building'></i>Business Buzz".html_safe
    elsif current_page?(subtopic_path(@city, @lets_talk, @grinds_gears)) 
      return "<i class='fab fa-whmcs'></i>Grinds My Gears".html_safe
    elsif current_page?(subtopic_path(@city, @lets_talk, @sports)) 
      return "<i class='fas fa-football-ball'></i>Sports".html_safe
    elsif current_page?(subtopic_path(@city, @city_affairs, @ballots)) 
      return "<i class='fas fa-newspaper'></i>Ballots".html_safe
    elsif current_page?(subtopic_path(@city, @city_affairs, @city_improvements)) 
      return "<i class='fas fa-road'></i>City Improvements".html_safe
    elsif current_page?(subtopic_path(@city, @city_affairs, @events)) 
      return "<i class='fas fa-calendar-alt'></i>Events".html_safe
    elsif current_page?(subtopic_path(@city, @city_affairs, @schools)) 
      return "<i class='fas fa-school'></i>Schools".html_safe
    elsif current_page?(subtopic_path(@city, @good_vibes, @good_news)) 
      return "<i class='fas fa-smile'></i>Good News".html_safe
    elsif current_page?(subtopic_path(@city, @good_vibes, @furry_friends)) 
      return "<i class='fas fa-bone'></i>Furry Friends".html_safe
    elsif current_page?(subtopic_path(@city, @good_vibes, @city_snaps)) 
      return "<i class='fas fa-camera-retro'></i>City Snaps".html_safe
    elsif current_page?(subtopic_path(@city, @good_vibes, @local_historian)) 
      return "<i class='fas fa-atlas'></i>Local Historian".html_safe
    else
    end
  end   
  
  # Below -  CHeks all the sub pages of complaints.
  def complaints_page_check 
    return true if current_page?(controller: 'complaints', action: 'other') || current_page?(controller: 'complaints', action: 'roadkill') || current_page?(controller: 'complaints', action: 'obstruction') ||  current_page?(controller: 'complaints', action: 'lights') || current_page?(controller: 'complaints', action: 'snow') ||  current_page?(controller: 'complaints', action: 'weeds') || current_page?(controller: 'complaints', action: 'trash') || current_page?(controller: 'complaints', action: 'graffiti') || current_page?(controller: 'complaints', action: 'property') ||  current_page?(controller: 'complaints', action: 'sidewalk') || current_page?(controller: 'complaints', action: 'forestry') || current_page?(controller: 'complaints', action: 'potholes') || current_page?(controller: 'complaints', action: 'water') || current_page?(controller: 'complaints', action: 'verifying') || current_page?(controller: 'complaints', action: 'pending') || current_page?(controller: 'complaints', action: 'filed') || current_page?(controller: 'complaints', action: 'finished')      
  end   
  
  # Below -  Checks all departments subpages
  def departments_page_check 
    return true if current_page?(controller: 'department_reviews', action: 'government') || current_page?(controller: 'department_reviews', action: 'parks') || current_page?(controller: 'department_reviews', action: 'schools') || current_page?(controller: 'department_reviews', action: 'police') || current_page?(controller: 'department_reviews', action: 'public_works') 
  end   
  
end