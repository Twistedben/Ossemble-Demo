class SearchesController < ApplicationController 
  
  # Below - Before action that sets city to narrow down record returns
  before_action :set_city, only: [:ossembly_search, :community_search]
  # Below - Before action that
  
  def index 
    
  end 
  
  # Below - Action for searching of macro objects, render json for city and users, for ransack gem. Goes to views/searches/macro_search.json.jbuilder
    # And inherits easyAutoComplete JS and coffee file for macro-search.coffee.
  def macro_search
    @cities_search = City.ransack(name_cont: params[:q]).result(distinct: true).limit(5)
    @users_search  = User.ransack(name_cont: params[:q]).result(distinct: true).limit(6)
    respond_to do |format|
      format.json # Renders json for the macro_search.json.jbuilder file in views/searches folder
      format.html {
        flash[:alert] = "Please select a search result from the dropdown"
        redirect_to request.referrer
      }
    end    
  end 
  # Below - Action for searching inside Ossembly Forum, render json for petitions, posts, and subtopics, for ransack gem. 
    # Goes to views/searches/ossembly_search.json.jbuilder. JS is found in javascripts/ossembly-search.coffee
  def ossembly_search
    @subtopics_search  = Subtopic.ransack(name_cont: params[:q])
    @posts_search      = Post.ransack(name_cont: params[:q])
    @petitions_search  = Petition.ransack(name_cont: params[:q])
    @topics_search     = Topic.ransack(name_cont: params[:q])  
    respond_to do |format|
      format.json {
      
      if params[:q] == "Topics" || params[:q] == "Topic"
        @topics_search    = Topic.ransack({city_id: @city.id}).result
        @posts_search     = @posts_search.result.where(city_id: @city.id).none
        @petitions_search = @petitions_search.result.where(city_id: @city.id).none
        @subtopics_search = @subtopics_search.result.where(city_id: @city.id).none
      elsif params[:q] == "Subtopics" || params[:q] == "Subtopic"
        @topics_search    = @topics_search.result.where(city_id: @city.id).none 
        @posts_search     = @posts_search.result.where(city_id: @city.id).none
        @petitions_search = @petitions_search.result.where(city_id: @city.id).none
        @subtopics_search = Subtopic.ransack({city_id: @city.id}).result
      else
        @posts_search     = @posts_search.result.where(city_id: @city.id)
        @topics_search    = @topics_search.result.where(city_id: @city.id) 
        @petitions_search = @petitions_search.result.where(city_id: @city.id)
        @subtopics_search = @subtopics_search.result.where(city_id: @city.id)
      end
      }  
=begin   
      format.html {
        flash[:alert] = "Please select a search result from the dropdown"
        redirect_to request.referrer
      }
=end
    end    
  end 
  # Below - Action for searching inside Community Score, render json for complaints, dep reviews, and city reviews, for ransack gem.
    # Goes to views/searches/community_search.json.jbuilder. JS is found in javascripts/community-search.coffee

  def community_search
    @complaints_search         = Complaint.ransack(name_cont: params[:q])
    @department_reviews_search = DepartmentReview.ransack(name_cont: params[:q])
    @city_reviews_search       = CityReview.ransack(name_cont: params[:q])
    respond_to do |format|
      format.json {
        @complaints_search = @complaints_search.result.where(city_id: @city.id)
        @department_reviews_search = @department_reviews_search.result.where(city_id: @city.id)
        @city_reviews_search = @city_reviews_search.result.where(city_id: @city.id)
      } # Renders json for the macro_search.json.jbuilder file in views/searches folder
      format.html {
        flash[:alert] = "Please select a search result from the dropdown"
        redirect_to request.referrer
      }
    end    
  end 
  
  private 
  
  def force_json 
    request.format = :json
  end 
  # Below -  Grabs city from params for ossembly and community search.
  def set_city 
    @city = City.friendly.find(params[:city_id])
  end   
  
end