module DepartmentReviewsHelper
# Main helper methods for Department Reviews.
  # Below -  Displays the different icons associated with Departments dependent on their respective categories.
  def display_department_icons(department)
    case department.category 
    when "Parks"
      image_tag "icons/park.png", alt: "Parks Icon", id: "parks_icon", class: "m-0 relative", style: "top: 8px;"
    when "Government"
      "<i class='department_icon fas fa-university m-0 relative' style='top: 8px'></i>".html_safe
    when "Schools"
      "<i class='department_icon fas fa-graduation-cap m-0 relative' style='top: 8px'></i>".html_safe
    when "Police"
      "<i class='department_icon fas fa-taxi m-0 relative' style='top: 8px'></i>".html_safe
    when "Public Works"
      "<i class='department_icon fas fa-bus-alt m-0 relative' style='top: 8px'></i>".html_safe
    else
      #Renders default icon as a fail-safe 
      "<i class='department_icon fas fa-university m-0 relative' style='top: 8px'></i>".html_safe
    end 
  end   
  
  # Below -  Returns the link for the filter tag dependent on the argument's categpry
  def department_filter_link(department) 
    case department.category 
    when "Parks"
      link_to "#{department.category}", parks_city_department_reviews_path(department.institute), class: 'btn mr-3 alt-action'      
    when "Government"
      link_to "#{department.category}", government_city_department_reviews_path(department.institute), class: 'btn mr-3 alt-action'      
    when "Schools"
      link_to "#{department.category}", schools_city_department_reviews_path(department.institute), class: 'btn mr-3 alt-action'      
    when "Police"
      link_to "#{department.category}", police_city_department_reviews_path(department.institute), class: 'btn mr-3 alt-action'
    when "Public Works"
      link_to "#{department.category}", public_works_city_department_reviews_path(department.institute), class: 'btn mr-3 alt-action'
    else
      #Renders an empty link as a failsafe
      link_to "Department", city_department_reviews_path(department.institute), class: 'btn mr-3 alt-action'
    end 
  end   

end
