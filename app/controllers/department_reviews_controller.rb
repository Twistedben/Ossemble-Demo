class DepartmentReviewsController < ApplicationController
# Main controller for department reviews.
  before_action :set_review, only: [:show, :edit, :update, :destroy, :upvote]
  # Below - Sets City for method actions of City Review.
  before_action :set_city, except: [:edit, :update, :destroy] 
  # Below - Sets user related params and IDs, city, review and user
  before_action :set_user_params, only: [:edit, :update, :destroy]
  # Below - Multiples the score value that is initially 1 out of 5 and factors it by 20.
  before_action :multiply_score, only: [:create, :update]

  def index
    if params[:sort_by] == "score"
      @reviews = @city.department_reviews.sort_by { |dr| dr.score }
      @reviews.reverse!
    elsif params[:sort_by] == "date"
      @reviews = @city.department_reviews.order('created_at DESC')
    elsif params[:sort_by] == "endorsements"
      @reviews = @city.department_reviews.sort_by { |dr| dr.votes_for.size }
      @reviews.reverse!
    elsif params[:sort_by] == "comments"
      @reviews = @city.department_reviews.sort_by { |dr| dr.count_comments }
      @reviews.reverse!
    elsif params[:sort_by] == "trending"
      @reviews = @city.department_reviews.sort_by { |dr| dr.hits }
      @reviews.reverse!
    else 
      @reviews = @city.department_reviews.sort_by { |dr| dr.hits }
      @reviews.reverse!
      @week_reviews = @city.department_reviews.most_hit(1.week.ago, 10)
      @month_reviews = @city.department_reviews.most_hit(1.month.ago, nil).offset(10)    
    end 
  end

  def show
    # Below - adds punch counter to City Review for trending.
    @review.punch(request)
    @review_comments = @review.comments
    # Below - Sets up sharing meta-tags for reviews.
    if @review.image.attached?
      set_meta_tags title: @review.title,
        site: 'Ossemble',
        description: @review.description, 
        keywords: @review.love_list + @review.improve_list,
        image_src: url_for(@review.image),
        twitter: {
          site: "@ossemble",
          title: @review.title,
          description: @review.description,
          image: url_for(@review.image)
        },
        og: {
          type: "website",
          title: @review.title,
          url: city_department_review_url(@city, @review),
          description: @review.description,
          image: url_for(@review.image)
        }
    else 
      set_meta_tags title: @review.title,
        site: 'Ossemble',
        description: @review.description, 
        keywords: @review.love_list + @review.improve_list,
        twitter: {
          site: "@ossemble",
          title: @review.title,
          description: @review.description
        },
        og: {
          type: "website",
          title: @review.title,
          url: city_department_review_url(@city, @review),
          description: @review.description
        }
    end 
  end
  
  def new
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to new page.
      flash[:alert] = "You must join Ossemble to review a #{@city.name} Department."
      cookies[:stored_location] = new_city_department_review_path(@city)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      @review = @city.department_reviews.new
      authorize @review # Ensures user belongs to city they're reviewing.
    end
  end

  def create
    @review = @city.department_reviews.build(review_params)
    # Below - Sets the Review user id to current users.
    @review.user_id = current_user.id 
    # Below - Sets the Review polymorphic scorable id to the associated city id, which should match the City Score ID column.
    if @review.scorable_type == "GovernmentScore"  
      @review.scorable_id = @city.city_score.government_score.id
    elsif @review.scorable_type == "ParkScore"
      @review.scorable_id = @city.city_score.park_score.id
    elsif @review.scorable_type == "SchoolScore"
      @review.scorable_id = @city.city_score.school_score.id
    elsif @review.scorable_type == "PoliceScore"
      @review.scorable_id = @city.city_score.police_score.id
    elsif @review.scorable_type == "PublicScore"
      @review.scorable_id = @city.city_score.public_score.id
    end 
    authorize @review # Ensures user belongs to city they're reviewing.
    if @review.save
      # Below - Adds to a users activity stream when creating a new city review (WUL) and assigns the city as the recipient of it.
      @review.create_activity :create, owner: current_user, recipient: @review.city
      flash[:notice] = "Your #{@review.category} Department review for #{@city.name} has been successfully submitted!"   # Shows a Flash message of success
      #upgrade_badge(current_user, 'Ownership', 75) # Upgrade the ownership badge
      redirect_to city_department_review_path(@city, @review)  # Redirects to the Review's show page.
    else
      flash[:alert] = "Could not submit your #{@review.category} Department review for #{@city.name}. See why below!"   # Shows a Flash message of error
      
      render 'new' # Reload the New template with errors
    end # End - If statement for review creation.
  end
  
  def edit
    # Finds the review, city and user
    authorize @review # Ensures user is owner of  review.
  end

  def update
    # Finds the review, city and user
    authorize @review # Ensures user is owner of  review.
    if @review.update(review_params)
      flash[:notice] = "Your #{@review.category} Department review for #{@city.name} has been updated successfully!"
      redirect_to city_department_review_path(@city, @review)  # Redirects to the Review's show page.
    else 
      flash[:alert] = "Your #{@review.category} Department review for #{@city.name} could not be updated. See why below!"   # Shows a Flash message of error
      render 'edit'
    end 

  end

  def destroy
    # Finds the review, city and user
    authorize @review # Ensures user is owner of  review.
    if @review.user === current_user
      if @review.destroy
        flash[:notice] = "Your department review for #{@user.city.name} has been deleted."
        redirect_to city_department_reviews_path(@city)
      else 
        flash[:alert] = "Your department review for #{@user.city.name} could not be deleted for some unknown reason. Please contact us."
        render 'edit'
      end
    end
  end
  
# Begin - Filters for Departments. Routes set up in Collection Do Block. Scopes grabbed from Department.rb model.
  # Below - Filters for Government departments from government scope.
    def government 
     if params[:sort_by] == "score"
        @reviews = @city.department_reviews.government.sort_by { |dr| dr.score }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @reviews = @city.department_reviews.government.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @reviews = @city.department_reviews.government.sort_by { |dr| dr.votes_for.size }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "comments"
        @reviews = @city.department_reviews.government.sort_by { |dr| dr.count_comments }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @reviews = @city.department_reviews.government.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      else 
        @reviews = @city.department_reviews.government.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      end 
    end   
  # Below - Filters for School departments from schools scope.   
    def schools 
      if params[:sort_by] == "score"
        @reviews = @city.department_reviews.schools.sort_by { |dr| dr.score }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @reviews = @city.department_reviews.schools.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @reviews = @city.department_reviews.schools.sort_by { |dr| dr.votes_for.size }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "comments"
        @reviews = @city.department_reviews.schools.sort_by { |dr| dr.count_comments }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @reviews = @city.department_reviews.schools.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      else 
        @reviews = @city.department_reviews.schools.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      end 

    end 
  # Below - Filters for parks departments from parks scope.
    def parks 
     if params[:sort_by] == "score"
        @reviews = @city.department_reviews.parks.sort_by { |dr| dr.score }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @reviews = @city.department_reviews.parks.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @reviews = @city.department_reviews.parks.sort_by { |dr| dr.votes_for.size }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "comments"
        @reviews = @city.department_reviews.parks.sort_by { |dr| dr.count_comments }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @reviews = @city.department_reviews.parks.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      else 
        @reviews = @city.department_reviews.parks.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      end 
    end   
  # Below - Filters for parks departments from parks scope.
    def police 
      if params[:sort_by] == "score"
        @reviews = @city.department_reviews.police.sort_by { |dr| dr.score }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @reviews = @city.department_reviews.police.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @reviews = @city.department_reviews.police.sort_by { |dr| dr.votes_for.size }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "comments"
        @reviews = @city.department_reviews.police.sort_by { |dr| dr.count_comments }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @reviews = @city.department_reviews.police.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      else 
        @reviews = @city.department_reviews.police.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      end 
    end   
  # Below - Filters for parks departments from parks scope.
    def public_works 
      if params[:sort_by] == "score"
        @reviews = @city.department_reviews.public_works.sort_by { |dr| dr.score }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @reviews = @city.department_reviews.public_works.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @reviews = @city.department_reviews.public_works.sort_by { |dr| dr.votes_for.size }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "comments"
        @reviews = @city.department_reviews.public_works.sort_by { |dr| dr.count_comments }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @reviews = @city.department_reviews.public_works.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      else 
        @reviews = @city.department_reviews.public_works.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      end 
    end   
# End - Filters for Departments. Routes set up in Collection Do Block. Scopes grabbed from Department.rb model.

  # Below - Acts_as_votable Controller methods for department reviews.  
  def upvote
    # Finds the review, city and user.
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to show page.
      flash[:alert] = "You must create an account and join #{@review.city.name} to endorse this Department Review."
      cookies[:stored_location] = city_department_review_path(@city, @review)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      # Begin - If statement to check for user voting on their own  review or not.
      if @review.user != current_user            # User who is voting for the review is not the user who created it.     
        # Begin - If statement for determining if user has already voted for review or not.
        if current_user.voted_for? @review       # Checks for :true if user has already voted for review. Goes to Else if user has not yet voted for city review.
          # Below - User has not yet voted for city review and user has not posted the city review they're voting for.
          flash[:warning] = "You have already endorsed this #{@review.category} Department Review, posted by #{@review.user.name}"
          redirect_to request.referrer
        else # User is voting on the City Review for the first time.
          authorize @review # Ensures user belongs to city of review they're upvoting.
          # Below - User has passed both if statments to successfully vote for the Review.
          @review.upvote_by current_user               #  Currenty user votes.
          if @review.save                              # Vote by user is successfully committed to DB
            Notification.create(recipient: @review.user, actor: current_user, action: "endorsed", notifiable: @review)
            #upgrade_badge(current_user,"Gratitude",5)     # upgrade gratitude badge for current user
            #upgrade_badge(@review.user,"Communication",10)  # upgrade communication badge for review user
            # Below - Adds to a users activity stream when endorsing a review and assigns recipient to the owner of it.
            @review.create_activity :upvote, owner: current_user, recipient: @review.user
            @review.punches.create(hits: 2)            # Adds 2 to trending counter when review is voted on.
            flash[:notice] = "You have successfully endorsed this #{@review.category} Department review for #{@review.city.name}, posted by #{@review.user.name}"
            redirect_to request.referrer
          else  # For some reason, user couldn't vote for city review.
            flash[:alert] = "Could not endorse this #{@review.category} Department review for #{@review.city.name}. Please contact us."
            redirect_to request.referrer
          end   # End - If statement of user voting for city review.
        end   # End - If statement for determining if user has already voted for city review or not.
      else  # User who is voting for the city review is the user who created the city review.
        flash[:alert] = "You cannot endorse your own Department Review."
        redirect_to request.referrer
      end  # End - If statement to check for user voting on their own city review or not.
    end # End of Guest check
  end


  
  private 
    
    # Below -  Runs the if / elsif statement to display sorting for department reviews.
    def sorting_logic
      if params[:sort_by] == "score"
        @reviews = @city.department_reviews.sort_by { |dr| dr.score }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @reviews = @city.department_reviews.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @reviews = @city.department_reviews.sort_by { |dr| dr.votes_for.size }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "comments"
        @reviews = @city.department_reviews.sort_by { |dr| dr.count_comments }
        @reviews.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @reviews = @city.department_reviews.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      else 
        @reviews = @city.department_reviews.sort_by { |dr| dr.hits }
        @reviews.reverse!
        render action: :index
      end 
    end   
    # Below -  Passes in strong params for the modification or creation of a Department Review.
    def review_params
      params.require(:department_review).permit(:id, :title, :description, :score, :city_id, :user_id, :scorable_id, :scorable_type, :love_list, :improve_list, :image)
    end   
    # Below - Sets review
    def set_review
      @review = DepartmentReview.friendly.find(params[:id])
    end
    # Below - Sets city and department
    def set_city
      @city = City.friendly.find(params[:city_id])
    end 
    # Below - Sets user from params when editing/destroying/updating 
    def set_user_params 
      @user = User.friendly.find(params[:user_id])
      @review = DepartmentReview.friendly.find(params[:id])
      @city = @review.city
      @scorable = @review.scorable_type
    end 
    
    # Takes the user submitted Score value (1..1.5..) out of 5, empties the existing params (:score),
      # multiplies it by 20 to get a percentage value out of 100, and reassigns the params to the newly
        # multiplied value.
    def multiply_score
      user_score = params[:department_review].delete(:score).to_f
      score = user_score * 20
      params[:department_review][:score] = score
    end

end
