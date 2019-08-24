class CitiesController < ApplicationController
# Ossemble's Main Controller for Cities.

  def index
    @cities = City.all
  end
  
  def show 
    @city = City.friendly.find(params[:city_id])
    @community_score = @city 
    # Begin -  TRENDING: Trending instance variables for rendering on city show page for main feed.
      # Below - Week's trending resources
      @trending_week_posts         = @city.posts.most_hit(1.week.ago, 3)
      @trending_week_complaints    = @city.complaints.not_completed.most_hit(1.week.ago, 3) 
      @trending_week_petitions     = @city.petitions.most_hit(1.week.ago, 3)
      @trending_week_departments   = @city.department_reviews.most_hit(1.week.ago, 3)
      @trending_week_city_reviews  = @city.city_reviews.most_hit(1.week.ago, 3)
      @trending_week_concerns      = @city.concerns.most_hit(1.week.ago, 3)
      # Below - Adds all trending resources for a city 
      @week_city_resources         = @trending_week_concerns + @trending_week_posts + @trending_week_complaints + @trending_week_petitions + @trending_week_departments + @trending_week_city_reviews
      # Below - Fakes a trending week feed for now of the most hit resources. TODO: Find a way to throw the most hit at the top
      @trending_week_resources     = @week_city_resources.shuffle!
      # Below - Month's trending resources
      @trending_month_posts        = @city.posts.most_hit(1.month.ago, 8).offset(3)
      @trending_month_complaints   = @city.complaints.not_completed.most_hit(1.month.ago, 8).offset(3)
      @trending_month_petitions    = @city.petitions.most_hit(1.month.ago, 8).offset(3)
      @trending_month_departments  = @city.department_reviews.most_hit(1.month.ago, 8).offset(3)
      @trending_month_city_reviews = @city.city_reviews.most_hit(1.month.ago, 8).offset(3)
      @trending_month_concerns = @city.concerns.most_hit(1.month.ago, 8).offset(3)
      # Below - Adds all month trending resources above together to render in City Show page, city_feed 
      @month_city_resources        = @trending_month_concerns + @trending_month_posts + @trending_month_complaints + @trending_month_petitions + @trending_month_departments + @trending_month_city_reviews
      # Below - Fakes a trending month feed for now of the most hit resources. TODO: Find a way to throw most hit at top
      @trending_month_resources    = @month_city_resources.shuffle!
      
    # End - TRENDING
    

  end
=begin
  def community_search
    @city = City.friendly.find(params[:city_id])
    @complaints_search         = Complaint.ransack(name_cont: params[:q])
    @department_reviews_search = DepartmentReview.ransack(name_cont: params[:q])
    @city_reviews_search       = CityReview.ransack(name_cont: params[:q])
    respond_to do |format|
      format.json { 
          @complaints_search         = @complaints_search
          @department_reviews_search = DepartmentReview.ransack(name_cont: params[:q])
          @city_reviews_search       = CityReview.ransack(name_cont: params[:q])

        render :file => '/searches/community_search.json'
        }# Renders json for the macro_search.json.jbuilder file in views/searches folder
      format.html {
        flash[:alert] = "Please select a search result from the dropdown"
        redirect_to request.referrer
      }
    end    
  end 
=end
  
  def new
    @city = City.new
  end
  
  def create
    @city = City.new(city_params)

    
    respond_to do |format|
      if @city.save
       
        format.html { redirect_to @city, notice: 'City was successfully created.' }
        format.json { render :show, status: :created, location: @city }
      
      else
        format.html { render :new }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end 

  # Page for index of complaints + concerns (reports + suggestions)
  def map_pins 
    @city = City.friendly.find(params[:city_id])
    @map_pins = @city.complaints + @city.concerns
  end 

  private 
  
    # Below -  
    def force_json 
       request.format = :json
    end   
    def set_city
      @city = City.find(params[:id])
    end

    def city_params
      params.require(:city).permit(:name, :zip, :state)
    end

end
