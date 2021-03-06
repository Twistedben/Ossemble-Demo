module SortPanelHelper
# Main helper for Sort Panel and rendering links to different pages' sorting feature. 
  # Below - Helper method that adds sorting buttons for the sort_panel partial in layouts (layouts/_sort_panel.html.erb)
  def sort_panel(title, sort, page)
    case page
    when "com_index"
      link_to "#{title}", city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "verifying"
      link_to "#{title}", verifying_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "pending"
      link_to "#{title}", pending_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "filed"
      link_to "#{title}", filed_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"      
    when "finished"
      link_to "#{title}", finished_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "other"
      link_to "#{title}", other_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "roadkill"
      link_to "#{title}", roadkill_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "obstruction"
      link_to "#{title}", obstruction_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "lights"
      link_to "#{title}", lights_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "snow"
      link_to "#{title}", snow_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "weeds"
      link_to "#{title}", weeds_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "trash"
      link_to "#{title}", trash_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "graffiti"
      link_to "#{title}", graffiti_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "property"
      link_to "#{title}", property_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "sidewalk"
      link_to "#{title}", sidewalk_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "forestry"
      link_to "#{title}", forestry_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "potholes"
      link_to "#{title}", potholes_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "water"
      link_to "#{title}", water_city_complaints_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "dep_index"
      link_to "#{title}", city_department_reviews_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "government"
      link_to "#{title}", government_city_department_reviews_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "schools"
      link_to "#{title}", schools_city_department_reviews_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "parks"
      link_to "#{title}", parks_city_department_reviews_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "police"
      link_to "#{title}", police_city_department_reviews_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "public_works"
      link_to "#{title}", public_works_city_department_reviews_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "cr_index"
      link_to "#{title}", city_review_index_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "cr_loves"
      link_to "#{title}", loves_city_review_index_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "cr_improves"
      link_to "#{title}", improves_city_review_index_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "topics"
      link_to "#{title}", city_topic_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "subtopics"
      link_to "#{title}", subtopic_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "pet_index"
      link_to "#{title}", city_petitions_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "pet_pending"
      link_to "#{title}", pending_city_petitions_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "pet_filed"
      link_to "#{title}", filed_city_petitions_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
      
    when "con_index"
      link_to "#{title}", city_concerns_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "con_reports"
      link_to "#{title}", reports_city_concerns_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    when "con_suggestions"
      link_to "#{title}", suggestions_city_concerns_path(sort_by: "#{sort}"), class: "dropdown-item py-2"
    end
  end
 
end
