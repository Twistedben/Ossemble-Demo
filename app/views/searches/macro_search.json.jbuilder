# Json for searching cities and users in the search bar in the navbar. Refers to macro-search.coffee in /javascripts for js code
  # Refers to searches_controller.rb for ransack and json return, macro_search action.
  
# Below - Returns searched cities name, the route on click, and the location, which is the state and zip.
json.cities do 
  json.array!(@cities_search) do |city| 
    json.name city.name 
    json.url city_feed_path(city) 
    json.location "#{city.state_name}, #{city.county.name}"
  end 
end 

# Below - Returns searched users' name, the route on click, and the location, which is the state and city name.
json.users do 
  json.array!(@users_search) do |user| 
    json.name user.name 
    
    json.url user_path(user.city, user)
    json.location "#{user.city.name}, " + "#{user.state}"
  end 
end 
