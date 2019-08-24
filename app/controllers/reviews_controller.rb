class ReviewsController < ApplicationController
# Main Reviews Controller.
  # Below - Sets the review instance for show edit update and destroy
  before_action :set_review, only: [:show, :edit, :update, :destroy]
  # Below - Multiples the score value that is initially 1 out of 5 and factors it by 20.
  before_action :multiply_score, only: [:create, :update]
  # Below - Sets the department
  before_action :set_city_department, except: [:edit, :update]
 
  def index
    @reviews = Review.all
  end

  def show
  # Before_Action @review object
     set_meta_tags title: @review.title,
            site: 'Ossemble',
            description: @review.description, 
            keywords: @review.score
  end

  def new
    @review = @department.reviews.new
    authorize @review # Ensures user belongs to the city they're reviewing within.
  end

  # Below - Create accesses the following routes: Prefix/Path: "create_city_department_review" | Verb: "POST"    
    # URI/URL: "/cities/:city_id/departments/:department_id/reviews(.:format)"  | Controller/Action: "reviews#create"
  def create
    # Before Action =  Finds and assigns the current City and department the User is reviewing.
    # Below -  Creates the Review for the department using the "review_params" method in "private" below, passing
      # attributes for the :score, :description, :department_id, and :city_id, and assigning the Review to the Department above it.
    @review = @department.reviews.build(review_params)
    # Below - Assigns the Review being created to the currently logged in User.
    @review.user = current_user
    authorize @review # Ensures user belongs to the city they're reviewing within.
    # Begin - If statement for determining if the Review was committed to the DB successfully, then rendering the Reviews 
      # for the specific department & a success message, or displaying an error and rendering a new form page.
    if @review.save # If it saves, display Flash message success, if not move to 'else'
      # Below - Adds to a users activity stream when creating a department review and assigns the city as the recipient.
      @review.create_activity :create, owner: current_user, recipient: @review.city
      @department.punches.create(hits: 3)                   # Adds 4 to trending counter when department is reviewed.
      flash[:notice] = "Your review for #{@department.name} has been successfully posted!"   # Shows a Flash message of success
      redirect_to city_department_path(@city, @department)  # Redirects to the Department's show page.
    else
      flash[:alert] = "Could not post your review for #{@department.name}. See why below!"   # Shows a Flash message of error
      render 'new' # Reload the New template with errors
    end # End - If statement for review creatoin.
  end

  def edit
    authorize @review # Ensures user owns the review they're editing or is a mod.
  end

  def update
    authorize @review # Ensures user owns the review they're editing or is a mod.
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @review, notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @review # Ensures user owns the review they're destroying or is a mod.
    @review.destroy
    respond_to do |format|
      format.html { redirect_to reviews_url, notice: 'Review was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

 # Begin - Acts_as_votable Controller method for Reviews.
  def upvote 
    # Begin - If statement to check for user voting on their own city review or not.
    if @review.user != current_user            # User who is voting for the city review is not the user who created it.     
      # Begin - If statement for determining if user has already voted for city review or not.
      if current_user.voted_for? @review       # Checks for :true if user has already voted for city review. Goes to Else if user has not yet voted for city review.
        # Below - User has not yet voted for city review and user has not posted the city review they're voting for.
        flash[:warning] = "You have already endorsed this post by #{@review.user.name}"
        redirect_to request.referrer
      else # User is voting on the City Review for the first time.
      # Below - User has passed both if statments to successfully vote for the City Review.
        @review.upvote_by current_user               # Current user votes.
        if @review.save                              # Vote by user is successfully committed to DB
          # Below - Adds to a users activity stream when upvoting a department review and assigns reviews' creator as the recipient.
          @review.create_activity :upvote, owner: current_user, recipient: @review.user
          @review.punches.create(hits: 2)            # Adds 2 to trending counter when city review is voted on.
          flash[:notice] = "You have successfully endorsed this #{@review.subtopic.name} post by #{@review.user.name}"
          redirect_to request.referrer
        else  # For some reason, user couldn't vote for city review.
          flash[:alert] = "Could not endorse this  #{@review.subtopic.name} post."
          redirect_to request.referrer
        end   # End - If statement of user voting for city review.
      end   # End - If statement for determining if user has already voted for city review or not.
    else  # User who is voting for the city review is the user who created the city review.
      flash[:alert] = "You cannot endorse your own post."
      redirect_to request.referrer
    end  # End - If statement to check for user voting on their own city review or not.
  end   # End - Sets up upvote method.
  # End - Acts_as_votable Controller methods for city_reviews.

  private
    # Below - Sets review
    def set_review
      @review = Review.find(params[:id])
    end
    # Below - Sets city and department
    def set_city_department
      @city = City.friendly.find(params[:city_id])
      @department = Department.friendly.find(params[:department_id])
    end 
    
    # Sets up Whitelisting for reviews
    def review_params
      params.require(:review).permit(:id, :description, :score, :department_id, :user_id)
    end
    
    # Takes the user submitted Score value (1..1.5..) out of 5, empties the existing params (:score),
      # multiplies it by 20 to get a percentage value out of 100, and reassigns the params to the newly
        # multiplied value.
    def multiply_score
      user_score = params[:review].delete(:score).to_f
      score = user_score * 20
      params[:review][:score] = score
    end
    
end
