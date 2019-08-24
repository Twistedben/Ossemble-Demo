class OssemblyController < ApplicationController
# Main controller for the Forum, displaying all posts and thier topics and subtopics. Inherits from Cities Controller.
  # Below - Before_action that sets the city ID.
  before_action :set_city
  # Below - Before_action that sets the instance variables for topics and subtopics filter panel.
  before_action :set_topics
  
  def index 
    # Below - Renders in posts trending within a week in all topics inside Ossembly.
    @trending_week_posts = @city.posts.most_hit(1.week.ago, 12)
    # Below - Renders in posts trending within a month in all topics inside Ossembly.
    @trending_month_posts = @city.posts.most_hit(1.month.ago, nil).offset(12)    
  end 

  private 
  
    # Below - Sets up the city for City Review
    def set_city
      @city = City.friendly.find(params[:city_id])
    end
    
    # Sets up all instance variables for the navigation of the filter panel within Ossembly. Used in all controllers inheriting from this. 
    def set_topics 
      # Below - All city topics for filter panel obj pass. 
      @ossembly = @city.topics
      # Below - Lets Talk topic and all corresponding subtopics.
      @lets_talk = @city.topics.find_by_name("Let's Talk")
        @general_talk = @city.subtopics.find_by_name("General Talk")
        @help_out = @city.subtopics.find_by_name("Help Me Out")
        @sports = @city.subtopics.find_by_name("Sports")
        @business_buzz = @city.subtopics.find_by_name("Business Buzz")
        @grinds_gears = @city.subtopics.find_by_name("Grinds My Gears")
      # Below - Good Vibes topic and all corresponding subtopics.
      @good_vibes = @city.topics.find_by_name("Good Vibes")
        @general_good = @city.subtopics.find_by_name("General Good")
        @good_news = @city.subtopics.find_by_name("Good News")
        @furry_friends = @city.subtopics.find_by_name("Furry Friends")
        @city_snaps = @city.subtopics.find_by_name("City Snaps")
        @local_historian = @city.subtopics.find_by_name("Local Historian")
      # Below - City Affairs topic and all corresponding subtopics.
      @city_affairs = @city.topics.find_by_name("City Affairs")
        @general_affairs = @city.subtopics.find_by_name("General Affairs")
        @ballots = @city.subtopics.find_by_name("Ballots")
        @schools = @city.subtopics.find_by_name("Schools")
        @city_improvements = @city.subtopics.find_by_name("City Improvements")
        @events = @city.subtopics.find_by_name("Events")
    end 
end
