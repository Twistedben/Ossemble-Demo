# Json for searching the community scores' complaints, department Reviews, and City Reviews in the search bar above list view. Refers to community-search.coffee in /javascripts for js code
  # Refers to searches_controller.rb for ransack and json return, community_search action.
  
# Below - Returns searched subtopics name, the route on click, and the subtopic's topic name.
json.subtopics do 
  json.array!(@subtopics_search) do |subtopic| 
    json.name subtopic.name 
    json.url subtopic_path(subtopic.city, subtopic.topic, subtopic) 
    json.extra_info "#{subtopic.topic.name}"
  end 
end 

# Below - Returns searched Posts, the title, and the post subtopic + topic.
json.posts do 
  json.array!(@posts_search) do |post| 
    json.name post.title 
    json.url subtopic_post_path(post.city, post.topic, post.subtopic, post) 
    json.extra_info "#{post.topic.name} / #{post.subtopic.name}"
  end 
end 

# Below - Returns searched Petitions, the title, and the process.
json.petitions do 
  json.array!(@petitions_search) do |petition| 
    json.name petition.title 
    json.url city_petition_path(petition.city, petition) 
    json.extra_info "#{petition.process}"
  end 
end 

# Below - Returns searched Topics, the name, and the description.
json.topics do 
  json.array!(@topics_search) do |topic| 
    json.name topic.name 
    json.url city_topic_path(topic.city, topic) 
    json.extra_info "#{topic.description.truncate(80)}"
  end 
end 
