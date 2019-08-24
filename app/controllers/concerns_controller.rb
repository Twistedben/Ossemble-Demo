class ConcernsController < ApplicationController
  # Below - Finds the current City ID associated with Concern.
  before_action :set_concern, only: [:show, :edit, :update, :destroy, :plan_submit, :replied, :completed, :upvote ]
  before_action :set_city, except: [:edit, :update, :destroy]
  before_action :set_user_and_city, only: [:edit, :update, :destroy]
  
  def index

    if params[:sort_by] == "date"
      @concerns = @city.concerns.order('created_at DESC')
    elsif params[:sort_by] == "title"
      concerns_array = @city.concerns
      @concerns = concerns_array.sort_by { |con| con.title.downcase }
    elsif params[:sort_by] == "comments"
      @concerns = @city.concerns.sort_by { |con| con.count_comments }
      @concerns.reverse!
    elsif params[:sort_by] == "endorsements"
      @concerns = @city.concerns.sort_by { |con| con.votes_for.size }
      @concerns.reverse!
    elsif params[:sort_by] == "trending"
      @concerns = @city.concerns.sort_by { |con| con.hits }
      @concerns.reverse!
    else 
      @concerns = @city.concerns.sort_by { |con| con.hits }
      @concerns.reverse!
      @week_concerns = @city.concerns.most_hit(1.week.ago, 10)
      @month_concerns = @city.concerns.most_hit(1.month.ago, nil).offset(10)
    end
  end

  def show
    # Below - adds punch counter to City Review for trending.
    @concern.punch(request)
  end

  def new
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to new page.
      flash[:alert] = "You must join Ossemble to voice a #{@city.name} Concern."
      cookies[:stored_location] = new_city_concern_path(@city)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      @concern = @city.concerns.new
      # authorize @concern # Ensures user is signed in and not a guest
    end
  end

  def create
    @concern = @city.concerns.build(concern_params)
    # Below - Assigns the Review being created to the currently logged in User.
    @concern.user_id = current_user.id
    # Begin - If statement for determining if the Concern was committed to the DB successfully, then rendering the Concerns 
      # for the specific city & a success message, or displaying an error and rendering a new form page.
    # authorize @concern # Ensures user is singed in and not a guest
    if @concern.save # If it saves, display Flash message success, if not move to 'else'
      # Below - Adds to a users activity stream when creating a concern and assigns the city as the recipient of concern.
      # @concern.create_activity :create, owner: current_user, recipient: @concern.city
      @concern.create_activity :create, owner: current_user, recipient: @concern.city
      flash[:notice] = "Your #{@concern.title} concern for #{@concern.city.name} was created successfully!" # Shows a Flash message of success.
      #upgrade_badge(current_user, 'Ownership', 100) # Upgrade the ownership badge
      #flash[:badge] = "Ownership badge +100!" # Shows a Flash message of success
      redirect_to city_concern_path(@city, @concern) # Redirects to the Concerns show path page.
    else
      flash[:alert] = "Concern could not be created. See why below!" # Shows a Flash message of failure.
      render 'new' # Reload the New template with errors.
    end # End - If statement for Concern saving
  end


  def edit
    # before action finding city, user.

  end
  
  def update
    # Calls all user related params and ids from a before action above.
    if @concern.update(concern_params)
      flash[:notice] = "Your Concern of #{@concern.city.name} has been updated successfully!"
      redirect_to city_concern_path(@city, @concern)
    else 
      flash[:alert] = "Your Concern of #{@concern.city.name} could not be updated. See why below!"
      render 'edit'
    end 
  end

  def destroy
    # Calls all user related params and ids from a before action above.
    if @concern.user === current_user
      if @concern.destroy
        flash[:notice] = "Your Concern for #{@user.city.name} has been deleted."
        redirect_to city_concerns_path(@city)
      else 
        flash[:alert] = "Your Concern for #{@user.city.name} could not be deleted for some unknown reason. Please contact us."
        render 'edit'
      end
    end
  end
  
  # Begin - Acts_as_votable Controller methods for concerns.
  def upvote 
    # Before action that Finds concern ID.
    # Before action that finds city for concern.
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to show page.
      flash[:alert] = "You must create an account and join #{@concern.city.name} to endorse this Concern."
      cookies[:stored_location] = city_concern_path(@city, @concern)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      # Begin - If statement to check for user voting on their own concern or not.
      if @concern.user != current_user            # User who is voting for the concern is not the user who created it.     
        # Begin - If statement for determining if user has already voted for concern or not.
        if current_user.voted_for? @concern       # Checks for :true if user has already voted for concern. Goes to Else if user has not yet voted for concern.
          # Below - User has not yet voted for concern and user has not posted the concern they're voting for.
          flash[:warning] = "You have already endorsed this Concern, posted by #{@concern.user.name}"
          redirect_to request.referrer
        else # User is voting on the concern for the first time.
          # Below - User has passed both if statments to successfully vote for the concern.
          @concern.upvote_by current_user               #  Currenty user votes.
          if @concern.save                              # Vote by user is successfully committed to DB
            Notification.create(recipient: @concern.user, actor: current_user, action: "endorsed", notifiable: @concern)
            # Below - Adds to a users activity stream when endorsing a concern and assigns recipient to the owner of it.
            @concern.create_activity :upvote, owner: current_user, recipient: @concern.user
            @concern.punches.create(hits: 2)            # Adds 2 to trending counter when concern is voted on.
            flash[:notice] = "You have successfully endorsed this #{@concern.city.name} Concern, posted by #{@concern.user.name}"
            redirect_to request.referrer
          else  # For some reason, user couldn't vote for concern.
            flash[:alert] = "Could not endorse this #{@concern.city.name} Concern. Please contact us."
            redirect_to request.referrer
          end   # End - If statement of user voting for concern.
        end   # End - If statement for determining if user has already voted for concern or not.
      else  # User who is voting for the concern is the user who created the concern.
        flash[:alert] = "You cannot endorse your own Concern."
        redirect_to request.referrer
      end  # End - If statement to check for user voting on their own concern or not.
    end # Guest check 
  end   # End - Sets up upvote method.
# End - Acts_as_votable Controller methods for concerns.
  
  
  def reports
    @concerns = @city.concerns.where(category: "Report")
    render action: :index
  end
  
  def suggestions
    @concerns = @city.concerns.where(category: "Suggestion")
    render action: :index
  end
  
  private
    
    def set_concern
      @concern = Concern.find(params[:id])
    end
  
    def set_city 
      @city = City.friendly.find(params[:city_id])
    end

    def concern_params
      params.require(:concern).permit(:address, :description, :latitude, :longitude, :title, :image, :category)
    end
    
    def set_user_and_city 
      @user = User.find(params[:user_id])
      @concern = Concern.find(params[:id])
      @city = @concern.city
    end 
end
