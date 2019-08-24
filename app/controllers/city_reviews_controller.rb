class CityReviewsController < ApplicationController
# Main controller for City Reviews
  before_action :set_city_review, only: [:show, :edit, :update, :destroy, :upvote]
  # Below - Sets City for method actions of City Review.
  before_action :set_city, except: [:edit, :update, :destroy] 
  # Below - Multiples the score value that is initially 1 out of 5 and factors it by 20.
  before_action :multiply_score, only: [:create, :update]
  # Below - Sets user related params and IDs 
  before_action :set_user_and_city, only: [:edit, :update, :destroy]

  def index
    # Begin - Sorting logic for city reviews (WUL). 
    if params[:sort_by] == "score"
      @city_reviews = @city.city_reviews.sort_by { |cr| cr.score }
      @city_reviews.reverse!
    elsif params[:sort_by] == "date"
      @city_reviews = @city.city_reviews.order('created_at DESC')
    elsif params[:sort_by] == "endorsements"
      @city_reviews = @city.city_reviews.sort_by { |cr| cr.votes_for.size }
      @city_reviews.reverse!
    elsif params[:sort_by] == "comments"
      @city_reviews = @city.city_reviews.sort_by { |cr| cr.count_comments }
      @city_reviews.reverse!
    elsif params[:sort_by] == "trending"
      @city_reviews = @city.city_reviews.sort_by { |cr| cr.hits }
      @city_reviews.reverse!
    else 
      @city_reviews = @city.city_reviews.sort_by { |cr| cr.hits }
      @city_reviews.reverse!
      @week_city_reviews = @city.city_reviews.most_hit(1.week.ago, 10)
      @month_city_reviews = @city.city_reviews.most_hit(1.month.ago, nil).offset(10)    
    end 
    # End - Sorting logic for city reviews (WUL). 
  end

  def show
    # Below - adds punch counter to City Review for trending.
    @city_review.punch(request)
    @city_review_comments = @city_review.comments
    # Below - Sets up meta tags for sharing city_review show pages.
    if @city_review.image.attached? # Image is attached
      set_meta_tags title: @city_review.title,
        site: 'Ossemble',
        description: @city_review.description, 
        keywords: @city_review.love_list + @city_review.improve_list,
        image_src: url_for(@city_review.image),
        twitter: {
          site: "@ossemble",
          title: @city_review.title,
          description: @city_review.description,
          image: url_for(@city_review.image)
        },
        og: {
          type: "website",
          title: @city_review.title,
          url: city_review_url(@city, @city_review),
          description: @city_review.description,
          image: url_for(@city_review.image)
        }
    else # Doesn't have an image
        set_meta_tags title: @city_review.title,
          site: 'Ossemble',
          description: @city_review.description, 
          keywords: @city_review.love_list + @city_review.improve_list,
          twitter: {
            site: "@ossemble",
            title: @city_review.title,
            description: @city_review.description
          },
          og: {
            type: "website",
            title: @city_review.title,
            url: city_review_url(@city, @city_review),
            description: @city_review.description
          }
    end
  end

  def new
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to new page.
      flash[:alert] = "You must join Ossemble to review #{@city.name}."
      cookies[:stored_location] = new_city_review_path(@city)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      @new_city_review = @city.city_reviews.new
      authorize @new_city_review # Ensures user is logged in
    end
  end
  
  def edit
    # Calls all user related params and ids from a before action above.
    authorize @city_review # Ensures user is owner of city review.
  end
  
  def create
    # Below -  Creates a WUL City Review for the city using the "city_review_params" method in "private" below, passing
      # attributes for the :title, :score, :description, :city_review_score_id, :user_id, and :city_id, taggings list (:love_list, :improve_list) and assigning the Review to the city.
    @new_city_review = @city.city_reviews.build(city_review_params)
    # Below - Sets the user id to the current user posting the city review
    @new_city_review.user_id = current_user.id 
    # Below - Sets the City Review Score Id to the associated city id which should match the City Score ID column.
    @new_city_review.city_review_score_id = @city.city_review_score.id
    # Begin - If statement for determining if the City Review was committed to the DB successfully, then rendering the City Reviews 
      # show page with a success message, or displaying an error and rendering a new form page.
    authorize @new_city_review # Ensures user belongs to the city they're reviewing.
    if @new_city_review.save # If it saves, display Flash message success, if not move to 'else'
      # Below - Adds to a users activity stream when creating a new city review (WUL) and assigns the city as the recipient of it.
      @new_city_review.create_activity :create, owner: current_user, recipient: @new_city_review.city
      flash[:notice] = "Your City Review for #{@city.name} has been successfully submitted!"   # Shows a Flash message of success
      redirect_to city_review_path(@city, @new_city_review)  # Redirects to the City Review's show page.
      #upgrade_badge(current_user, 'Ownership', 100) # Upgrade the ownership badge
    else
      flash[:alert] = "Could not submit your City Review for #{@city.name}. See why below!"   # Shows a Flash message of error
      render 'new' # Reload the New template with errors
    end # End - If statement for review creation.
  end

  def update
    # Calls all user related params and ids from a before action above.
    authorize @city_review # Ensures user is owner of city review.
    if @city_review.update(city_review_params)
      flash[:notice] = "Your City Review of #{@city_review.city.name} has been updated successfully!"
      redirect_to city_review_path(@city, @city_review)
    else 
      flash[:alert] = "Your City Review of #{@city_review.city.name} could not be updated. See why below!"
      render 'edit'
    end 
  end

  def destroy
    # Calls all user related params and ids from a before action above.
    authorize @city_review # Ensures user is destrroying thier own review.
    if @city_review.user === current_user
      if @city_review.destroy
        flash[:notice] = "Your City review for #{@user.city.name} has been deleted."
        redirect_to city_review_index_path(@city)
      else 
        flash[:alert] = "Your City review for #{@user.city.name} could not be deleted for some unknown reason. Please contact us."
        render 'edit'
      end
    end
  end
# Begin - Loves and Improves pages
  # Below -  Loves City Reviews (Score is > 60).
  def loves
    # Begin - Sorting logic for city reviews (WUL) for loves. 
    if params[:sort_by] == "score"
      @city_reviews = @city.city_reviews.loves.sort_by { |cr| cr.score }
      @city_reviews.reverse!
      render action: :index
    elsif params[:sort_by] == "date"
      @city_reviews = @city.city_reviews.loves.order('created_at DESC')
      render action: :index
    elsif params[:sort_by] == "endorsements"
      @city_reviews = @city.city_reviews.loves.sort_by { |cr| cr.votes_for.size }
      @city_reviews.reverse!
      render action: :index
    elsif params[:sort_by] == "comments"
      @city_reviews = @city.city_reviews.loves.sort_by { |cr| cr.count_comments }
      @city_reviews.reverse!
      render action: :index
    elsif params[:sort_by] == "trending"
      @city_reviews = @city.city_reviews.loves.sort_by { |cr| cr.hits }
      @city_reviews.reverse!
      render action: :index
    else 
      @city_reviews = @city.city_reviews.loves.sort_by { |cr| cr.hits }
      @city_reviews.reverse!
      render action: :index
    end 
    # End - Sorting logic for city reviews (WUL) for Loves. 
  end   

  # Below - Improves City Reviews (Score is < 60).
  def improves
    # Begin - Sorting logic for city reviews (WUL) improves. 
    if params[:sort_by] == "score"
      @city_reviews = @city.city_reviews.improves.sort_by { |cr| cr.score }
      @city_reviews.reverse!
      render action: :index
    elsif params[:sort_by] == "date"
      @city_reviews = @city.city_reviews.improves.order('created_at DESC')
      render action: :index
    elsif params[:sort_by] == "endorsements"
      @city_reviews = @city.city_reviews.improves.sort_by { |cr| cr.votes_for.size }
      @city_reviews.reverse!
      render action: :index
    elsif params[:sort_by] == "comments"
      @city_reviews = @city.city_reviews.improves.sort_by { |cr| cr.count_comments }
      @city_reviews.reverse!
      render action: :index
    elsif params[:sort_by] == "trending"
      @city_reviews = @city.city_reviews.improves.sort_by { |cr| cr.hits }
      @city_reviews.reverse!
      render action: :index
    else 
      @city_reviews = @city.city_reviews.improves.sort_by { |cr| cr.hits }
      @city_reviews.reverse!
      render action: :index
    end 
    # End - Sorting logic for city reviews (WUL) improves page. 
  end   
# End - Loves and Improves Pages
    
  # Begin - Acts_as_votable Controller methods for city_reviews.
    def upvote 
      # Before action that Finds city review ID.
      # Before action that finds city for city review.
      if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to show page.
        flash[:alert] = "You must create an account and join #{@city_review.city.name} to endorse this City Review."
        cookies[:stored_location] = city_review_path(@city, @city_review)
        redirect_to new_user_registration_path
      else # Is not a guest, so doesn't store location.  
        # Begin - If statement to check for user voting on their own city review or not.
        if @city_review.user != current_user            # User who is voting for the city review is not the user who created it.     
          # Begin - If statement for determining if user has already voted for city review or not.
          if current_user.voted_for? @city_review       # Checks for :true if user has already voted for city review. Goes to Else if user has not yet voted for city review.
            # Below - User has not yet voted for city review and user has not posted the city review they're voting for.
            flash[:warning] = "You have already endorsed this City Review, posted by #{@city_review.user.name}"
            redirect_to request.referrer
          else # User is voting on the City Review for the first time.
            authorize @city_review # Ensures user belongs to the city review they're upvoting.
            # Below - User has passed both if statments to successfully vote for the City Review.
            @city_review.upvote_by current_user               #  Currenty user votes.
            if @city_review.save                              # Vote by user is successfully committed to DB
              Notification.create(recipient: @city_review.user, actor: current_user, action: "endorsed", notifiable: @city_review)
              # Below - Adds to a users activity stream when endorsing a city review and assigns recipient to the owner of it.
              @city_review.create_activity :upvote, owner: current_user, recipient: @city_review.user
              @city_review.punches.create(hits: 2)            # Adds 2 to trending counter when city review is voted on.
              flash[:notice] = "You have successfully endorsed this #{@city_review.city.name} City Review."
              redirect_to request.referrer
            else  # For some reason, user couldn't vote for city review.
              flash[:alert] = "Could not endorse this #{@city_review.city.name} City Review. Please contact us."
              redirect_to request.referrer
            end   # End - If statement of user voting for city review.
          end   # End - If statement for determining if user has already voted for city review or not.
        else  # User who is voting for the city review is the user who created the city review.
          flash[:alert] = "You cannot endorse your own City Review."
          redirect_to request.referrer
        end  # End - If statement to check for user voting on their own city review or not.
      end # Guest check 
    end   # End - Sets up upvote method.
  # End - Acts_as_votable Controller methods for city_reviews.

  private

    # Below - Finds the City Review ID from the params
    def set_city_review
      @city_review = CityReview.friendly.find(params[:id])
    end
    # Below - Sets up the city for City Review
    def set_city
      @city = City.friendly.find(params[:city_id])
    end

    def city_review_params
      params.require(:city_review).permit(:id, :title, :description, :score, :user_id, :city_id, :city_review_score_id, :love_list, :improve_list, :image)
    end
    
    # Below - Sets up user related params on edit, update and destroy.
    def set_user_and_city 
      @user = User.friendly.find(params[:user_id])
      @city_review = CityReview.friendly.find(params[:id])
      @city = @city_review.city
      @city_review_edit = @city_review
    end 
    # Takes the user submitted Score value (1..1.5..) out of 5, empties the existing params (:score),
      # multiplies it by 20 to get a percentage value out of 100, and reassigns the params to the newly
        # multiplied value.
    def multiply_score
      user_score = params[:city_review].delete(:score).to_f
      score = user_score * 20
      params[:city_review][:score] = score
    end
    
end
