module ComplaintsHelper
# Main helper for Complaints
  # Below -  Determines process and the link acssociated with it.
  def complaint_process_link(complaint)
    case complaint.process 
    when "Needs Confirmation"
      return verifying_city_complaints_path(complaint.institute)
    when "Needs Endorsements"
      return pending_city_complaints_path(complaint.institute)
    when "Filed & Sent"
      return filed_city_complaints_path(complaint.institute)
    when "Completed" 
      return finished_city_complaints_path(complaint.institute)
    when "Failed" 
      return finished_city_complaints_path(complaint.institute)
    else # Fail safe if all else fails returns complaints index
      return city_complaints_path(complaint.institute)
    end 
  end
  # Below - Provides the sorting code for complaint controller pages. 
 
  # Below - Determines the sort_panel GET request for rendering what complaints to show when a filter tag's category is clicked
  def complaint_category_link(complaint) 
    case complaint.complaint_category_id
    when 2..5
      return other_city_complaints_path(@city)
    when 6
      return roadkill_city_complaints_path(@city)
    when 7
      return obstruction_city_complaints_path(@city)
    when 8
      return lights_city_complaints_path(@city)
    when 9
      return snow_city_complaints_path(@city)
    when 10
      return weeds_city_complaints_path(@city)
    when 11
      return trash_city_complaints_path(@city)
    when 12
      return graffiti_city_complaints_path(@city)
    when 13
      return property_city_complaints_path(@city)
    when 14
      return sidewalk_city_complaints_path(@city)
    when 15
      return forestry_city_complaints_path(@city)
    when 16
      return potholes_city_complaints_path(@city)
    when 17
      return water_city_complaints_path(@city)
    else #failsafe to link to index.
      return city_complaints_path(@city)
    end 
  end
  
  def concern_category_link(concern) 
    case concern.category
    when "Report"
      return reports_city_concerns_path(@city)
    when "Suggestion"
      return suggestions_city_concerns_path(@city)
    else #failsafe to link to index.
      return city_concern_path(@city)
    end 
  end
  
  # Below - Displays complaint's default icon by associated category on show page  
  def display_complaint_show_icon(complaint)
    # Below - Creates a div to contain the images for the different catgeories of a complaint.
    content_tag :div, :id => "icon_container" do
      case complaint.category
      when "Other"
        "<i class='fas fa-exclamation-triangle'></i>".html_safe
      when "Pothole"
        image_tag "icons/complaints/pothole.png", alt: "Pothole"    
      when "Roadkill"
        image_tag "icons/complaints/roadkill.png", alt: "Roadkill"
      when "Street Obstruction"
        image_tag "icons/complaints/obstruction.png", alt: "Obstruction" 
      when "Streetlights & Signs"
        image_tag "icons/complaints/streetlamp.png", alt: "Streelight"
      when "Snow Plowing"
        image_tag "icons/complaints/snowplow.png", alt: "Snow Plowing"
      when "Weeds & Grass"
        image_tag "icons/complaints/weeds.png", alt: "Weeds"
      when "Trash"
        image_tag "icons/complaints/trash.png", alt: "Trash"
      when "Graffiti"
        image_tag "icons/complaints/graffiti.png", alt: "Graffiti"
      when "Abandoned Property"
        image_tag "icons/complaints/abandon.png", alt: "Abandoned Property"
      when "Sidewalk"
        image_tag "icons/complaints/sidewalk.png", alt: "Sidewalk" 
      when "Forestry"
        image_tag "icons/complaints/forest.png", alt: "Forestry"
      when "Water Supply"
        image_tag "icons/complaints/flood.png", alt: "Water Supply"
      else
        "<i class='fas fa-exclamation-triangle'></i>".html_safe
      end # End - Complaint category check to render appropriate 
    end # End - Content tag for div icon container
  end
  
  
    # Below - Displays concern's default icon by associated category on show page  
  def display_concern_show_icon(concern)
    # Below - Creates a div to contain the images for the different catgeories of a complaint.
    content_tag :div, :id => "icon_container" do
      case concern.category
      when "Report"
         "<i class='fas fa-flag mt-2'></i>".html_safe
      when "Suggestion"
         "<i class='fas fa-comment-dots mt-2'></i>".html_safe
      else
        "<i class='fas fa-exclamation-triangle mt-2'></i>".html_safe
      end # End - Concern category check to render appropriate 
    end # End - Content tag for div icon container
  end   
  
end
