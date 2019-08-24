module WorkplaceMapPostsHelper
  
  # Below -  
  def map_category_filter_tag_url(map_post)
     if map_post.category == "Suggestion"
       workplace_map_suggestions_path(map_post.institute, map_post.workplace)
      elsif map_post.category == "Report"
        workplace_map_reports_path(map_post.institute, map_post.workplace)
      elsif map_post.category == "Other"
        workplace_map_others_path(map_post.institute, map_post.workplace)
      else 
        city_workplace_map_posts_path(map_post.institute, map_post.workplace)
      end 
  end   
end
