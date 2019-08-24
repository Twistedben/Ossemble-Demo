class TopicsController < OssemblyController
# Main controller for Topics and inherits from Ossembly Controller.
  # Below - Before_action that sets the city ID.
  before_action :set_city
  # Below - Before_action that sets the instance variables for topics/subtopics for filter panel, done in OssemblyController.
  before_action :set_topics
  # Below - Before_action that sets the topic id.
  before_action :set_topic

  
  def show
    if params[:sort_by] == "date"
      @week_topic_posts = @topic.posts.order('created_at DESC').limit(6)
      @month_topic_posts = @topic.posts.order('created_at DESC').offset(6)
    elsif params[:sort_by] == "endorsements"
      @week_topic_posts = @topic.posts.limit(6).sort_by { |p| p.votes_for.size }
      @week_topic_posts.reverse!      
      @month_topic_posts = @topic.posts.offset(6).sort_by { |p| p.votes_for.size }
      @month_topic_posts.reverse!
    elsif params[:sort_by] == "comments"
      @week_topic_posts = @topic.posts.limit(6).sort_by { |p| p.count_comments }
      @week_topic_posts.reverse!   
      @month_topic_posts = @topic.posts.offset(6).sort_by { |p| p.count_comments }
      @month_topic_posts.reverse!
    elsif params[:sort_by] == "trending"
      @week_topic_posts = @topic.posts.limit(6).sort_by { |p| p.hits }
      @week_topic_posts.reverse!      
      @month_topic_posts = @topic.posts.offset(6).sort_by { |p| p.hits }
      @month_topic_posts.reverse!
    else 
      # Below - Renders in all posts trending within a week inside of given topic.
      @week_topic_posts = @topic.posts.most_hit(1.week.ago, 6)
      # Below - Renders in all posts trending within a month inside of given topic.
      @month_topic_posts = @topic.posts.most_hit(1.month.ago, nil).offset(6)
      # Begin - Sorting logic for topics (Ossembly). 
    end 
    # End - Sorting logic for topics (Ossembly). 

  end


  private
    # Below - Sets up topic ID from URL.
    def set_topic
      @topic = Topic.friendly.find(params[:id])
    end

    
   
end
