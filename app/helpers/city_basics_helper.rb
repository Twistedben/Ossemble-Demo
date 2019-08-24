module CityBasicsHelper
  # Main helper module for city basic profile page.
  

  # Below -  
  def display_city_user_link(city_user)
    link_to city_user.name, city_basic_profile_path(city_user.institute, city_user), id: " " , class: "text-xmedium"
  end   
  
  
  
end 