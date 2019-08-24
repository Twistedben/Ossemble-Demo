# Json for searching the community scores' complaints, department Reviews, and City Reviews in the search bar above list view. Refers to community-search.coffee in /javascripts for js code
  # Refers to searches_controller.rb for ransack and json return, community_search action.
  
# Below - Returns searched complaints title, the route on click, and the complaint location and process
json.complaints do 
  json.array!(@complaints_search) do |complaint| 
    json.name complaint.title 
    json.url city_complaint_path(complaint.city, complaint) 
    json.extra_info "#{complaint.address}, #{complaint.process}"
  end 
end 

# Below - Returns searched Department Reviews, the title and the review category.
json.department_reviews do 
  json.array!(@department_reviews_search) do |review| 
    json.name review.title 
    json.url city_department_review_path(review.city, review) 
    json.extra_info "#{review.category}"
  end 
end 

# Below - Returns searched City Reviews, the title and the category: loves or improves.
json.city_reviews do 
  json.array!(@city_reviews_search) do |review| 
    json.name review.title 
    json.url city_review_path(review.city, review) 
    json.extra_info "#{review.category}"
  end 
end 
