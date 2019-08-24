module MapsHelper
# Helper methods for the map, such as setting initial zoom, returning city lat long, etc.  
  # Below -  First helper method called in the map, to set the map's center based on city's latitude longitude 
  def set_city_center(city) 
    "#{city.latitude}, #{city.longitude}"
  end   
  # Below - Sets initial zoom of a loaded Leaflet map based on city size in City's :size attribute, s, m, l  
  def set_map_initial_zoom(city_size)
    case city_size
    when  "l"
      10 
    when  "m" 
      11
    when  "s" 
      12
    else 
      9
    end
  end   
  
  # Below -  Set's the map post's shape's color based on the category of the post
  def set_shape_color(map_post)
    case map_post.category
    when "Suggestion"
      'blue'
    when "Report"
      'red'
    else
      'orange'
    end 
  end   
  
  # Below -  Set's the map post's marker's icon based on the category of the post
  def set_marker_icon(map_post)
    case map_post.category
    when "Suggestion"
      'fas fa-lightbulb text-21'
    when "Report"
      'fas fa-flag text-17'
    else
      'exclamation-circle'
    end 
  end   
  
  
end 