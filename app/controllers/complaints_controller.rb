class ComplaintsController < ApplicationController
# Main Complaint Controller.
  # Below - Finds the current Complaint ID.
  before_action :set_complaint, only: [:show, :edit, :update, :destroy, :plan_submit, :replied, :completed, :upvote ]
  # Below - Finds the current City ID associated with Complaint.
  before_action :set_city, except: [:edit, :update, :destroy]
  # Below - Before action that finds user and city.
  before_action :set_user_and_city, only: [:edit, :update, :destroy]
  # Below - Before action that ensures the city admin belongs to the city the complaint does.
  #before_action :authorize_city_admin, only: [:replied, :plan_submit, :completed]
  
  def index
    @complaint_time = Time.now
    # Begin - Sorting logic for Complaints. 
    if params[:sort_by] == "score"
      @complaints = @city.complaints.sort_by { |com| com.score}
      @complaints.reverse! 
    elsif params[:sort_by] == "date"
      @complaints = @city.complaints.order('created_at DESC')
    elsif params[:sort_by] == "title"
      complaints_array = @city.complaints
      @complaints = complaints_array.sort_by { |com| com.title.downcase }
    elsif params[:sort_by] == "comments"
      @complaints = @city.complaints.sort_by { |com| com.count_comments }
      @complaints.reverse!
    elsif params[:sort_by] == "endorsements"
      @complaints = @city.complaints.sort_by { |com| com.votes_for.size }
      @complaints.reverse!
    elsif params[:sort_by] == "trending"
      @complaints = @city.complaints.sort_by { |com| com.hits }
      @complaints.reverse!
    else 
      @complaints = @city.complaints.sort_by { |com| com.hits }
      @complaints.reverse!
      @week_complaints = @city.complaints.most_hit(1.week.ago, 10)
      @month_complaints = @city.complaints.most_hit(1.month.ago, nil).offset(10)
    end
    # Ending - Sorting logic for Complaints.
  end
  
  def show
    # Below - Updats complaints days left if the complaint is filed on load of show page
    @complaint.update_days_left if @complaint.filed? 

    # Below - adds punch counter to complaint.
    @complaint.punch(request)
    # Begin - Finds who verified the Complaint.
      @first_voter = @complaint.votes_for.first.voter_id unless @complaint.cached_votes_up == 0
      @verifying_voter = User.find @first_voter unless @first_voter == nil
    # End - Finds who verified the Complaint.
    @complaint_comments = @complaint.comments
    @vote_percentage = (@complaint.vote_threshold * 100).to_i
    @deadline = @complaint.days_left / 3 # This will need to be modified so that we can keep accurate time, otherwise days will always be 1 third.
    @complaint_deadline = @complaint.complaint_category.deadline / 3
    # Below - Sets up meta tags for sharing Complaints show page.
    if @complaint.image.attached?
      set_meta_tags title: @complaint.title,
        site: 'Ossemble',
        description: @complaint.description, 
        keywords: @complaint.address,
        image_src: url_for(@complaint.image),
        twitter: {
          site: "@Ossemble",
          title: @complaint.title,
          description: @complaint.description,
          image: url_for(@complaint.image) 
        },
        og: {
          type: "website",
          title: @complaint.title,
          url: city_complaint_url(@city, @complaint),
          description: @complaint.description,
          image: url_for(@complaint.image)
        }
    else # Complaint doesn't have an image attached
      set_meta_tags title: @complaint.title,
        site: 'Ossemble',
        description: @complaint.description, 
        keywords: @complaint.address,
        twitter: {
          site: "@Ossemble",
          title: @complaint.title,
          description: @complaint.description
          
        },
        og: {
          type: "website",
          title: @complaint.title,
          url: city_complaint_url(@city, @complaint),
          description: @complaint.description
        }
    end 
  end
  
  def new
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to new page.
      flash[:alert] = "You must join Ossemble to voice a #{@city.name} Complaint."
      cookies[:stored_location] = new_city_complaint_path(@city)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      @complaint = @city.complaints.new
      authorize @complaint # Ensures user is signed in and not a guest
    end 
  end
  
  def create
    @complaint = @city.complaints.build(complaint_params)
    # Below - Assigns the Review being created to the currently logged in User.
    @complaint.user_id = current_user.id
    # Assigns Complaint_score_ID to the City's ID so the tables are aligned properly, with the first entry in ComplaintScore being for Lakewood.
    @complaint.complaint_score_id = @city.complaint_score.id
    # Begin - If statement for determining if the Complaint was committed to the DB successfully, then rendering the Complaints 
      # for the specific city & a success message, or displaying an error and rendering a new form page.
    authorize @complaint # Ensures user is singed in and not a guest
    if @complaint.save # If it saves, display Flash message success, if not move to 'else'
      # Below - Adds to a users activity stream when creating a complaint and assigns the city as the recipient of complaint.
      @complaint.create_activity :create, owner: current_user, recipient: @complaint.city
      flash[:notice] = "Your #{@complaint.title} complaint for #{@complaint.city.name} was created successfully!" # Shows a Flash message of success.
      #upgrade_badge(current_user, 'Ownership', 100) # Upgrade the ownership badge
      #flash[:badge] = "Ownership badge +100!" # Shows a Flash message of success
      redirect_to city_complaint_path(@city, @complaint) # Redirects to the Complaints show path page.
    else
      flash[:alert] = "Complaint could not be created. See why below!" # Shows a Flash message of failure.
      render 'new' # Reload the New template with errors.
    end # End - If statement for Complaint saving
  end

  def edit
    # before action finding city, user.
    authorize @complaint # Ensures user is owner of complaint
  end
  
  def update
    # Before Action finding city, user.
    authorize @complaint # Ensures user is owner of complaint
    if @complaint.update(complaint_params)
      flash[:notice] = "Complaint has been updated successfully!"
      redirect_to city_complaint_path(@city, @complaint)
    else 
      flash[:alert] = "Complaint could not be updated. See why below!"
      render 'edit'
    end 
  end
  
  def destroy
    # BEfore action finds and sets complaint instance variable.
    authorize @complaint # Ensures user is owner of complaint
    if @complaint.user === current_user
      if @complaint.destroy
        flash[:notice] = "Your Complaint for #{@city.name} has been deleted."
        redirect_to city_complaints_path(@city)
      else 
        flash[:alert] = "Your Complaint for #{@city.name} could not be deleted for some unknown reason. Please contact us."
        render 'edit'
      end
    end
  end
  
# Begin - Filters for Complaints. Routes set up in Collection Do Block. Scopes grabbed from Complaint.rb model.
  # Below - Filters for verifying Complaints from verifying scope.
    def verifying 
      # Begin - Sorting logic for Complaints. 
      if params[:sort_by] == "date"
        @complaints = @city.complaints.verifying.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.verifying
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.verifying.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.verifying.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.verifying.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    # Ending - Sorting logic for Complaints.
    end   
    
  # Below - Filters for pending Complaints from pending scope.   
    def pending 
      if params[:sort_by] == "date"
        @complaints = @city.complaints.pending.order('verified_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.pending
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.pending.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.pending.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.pending.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.pending.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Filters for filed Complaints from filed scope.
    def filed 
      if params[:sort_by] == "score"
        @complaints = @city.complaints.filed.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.filed.order('filed_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.filed
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.filed.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.filed.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.filed.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.filed.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Filters for finished Complaints from completed and failed scope.
    def finished 
      if params[:sort_by] == "score"
        @complaints = @city.complaints.finished.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date-c"
        @complaints = @city.complaints.completed.order('completed_at DESC')
        render action: :index
      elsif params[:sort_by] == "date-f"
        @complaints = @city.complaints.failed.order('failed_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.finished
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.finished.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.finished.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.finished.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.finished.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
      # Below - Filtered map for Government Departments.
    def verifying_map
      @complaints = @city.complaints.verifying
      render action: :complaint_map
    end
  # Below - Filtered map for Schools Departments.
    def pending_map
      @complaints = @city.complaints.pending
      render action: :complaint_map
    end
  # Below - Filtered map for Parks Departments.
    def filed_map
      @complaints = @city.complaints.filed
      render action: :complaint_map
    end
  # Below - Filtered map for Parks Departments.
    def finished_map
      @complaints = @city.complaints.finished
      render action: :complaint_map
    end

  # Below - Map_view page for map_view.html.erb 
    def complaint_map
      @complaints = @city.complaints.all
      @verifying_complaints = @city.complaints.verifying
      @pending_complaints = @city.complaints.pending
      @filed_complaints = @city.complaints.filed
      @finished_complaints = @city.complaints.finished
    end
# End - Filters for Complaints. Routes set up in Collection Do Block. Scopes grabbed from Complaint.rb model.
# Begin -  Complaint Category Pages and Sorting Logic
  # Below - Page for Other Complaints and sorting logic for it.
    def other 
      if params[:sort_by] == "score"
        @complaints = @city.complaints.other.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.other.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.other
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.other.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.other.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.other.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.other.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for raodkill Complaints and sorting logic for it.
    def roadkill
      if params[:sort_by] == "score"
        @complaints = @city.complaints.roadkill.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.roadkill.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.roadkill
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.roadkill.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.roadkill.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.roadkill.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.roadkill.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for lights Complaints and sorting logic for it.
    def lights
      if params[:sort_by] == "score"
        @complaints = @city.complaints.lights.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.lights.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.lights
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.lights.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.lights.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.lights.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.lights.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for Obstruction Complaints and sorting logic for it.
    def obstruction
      if params[:sort_by] == "score"
        @complaints = @city.complaints.obstruction.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.obstruction.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.obstruction
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.obstruction.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.obstruction.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.obstruction.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.obstruction.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for snow Complaints and sorting logic for it.
    def snow
      if params[:sort_by] == "score"
        @complaints = @city.complaints.snow.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.snow.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.snow
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.snow.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.snow.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.snow.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.snow.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for weeds Complaints and sorting logic for it.
    def weeds
      if params[:sort_by] == "score"
        @complaints = @city.complaints.weeds.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.weeds.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.weeds
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.weeds.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.weeds.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.weeds.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.weeds.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for trash Complaints and sorting logic for it.
    def trash
      if params[:sort_by] == "score"
        @complaints = @city.complaints.trash.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.trash.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.trash
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.trash.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.trash.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.trash.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.trash.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for graffiti Complaints and sorting logic for it.
    def graffiti
      if params[:sort_by] == "score"
        @complaints = @city.complaints.graffiti.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.graffiti.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.graffiti
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.graffiti.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.graffiti.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.graffiti.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.graffiti.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for property Complaints and sorting logic for it.
    def property
      if params[:sort_by] == "score"
        @complaints = @city.complaints.property.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.property.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.property
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.property.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.property.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.property.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.property.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for sidewalk Complaints and sorting logic for it.
    def sidewalk
      if params[:sort_by] == "score"
        @complaints = @city.complaints.sidewalk.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.sidewalk.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.sidewalk
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.sidewalk.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.sidewalk.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.sidewalk.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.sidewalk.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for forestry Complaints and sorting logic for it.
    def forestry
      if params[:sort_by] == "score"
        @complaints = @city.complaints.forestry.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.forestry.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.forestry
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.forestry.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.forestry.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.forestry.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.forestry.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for potholes Complaints and sorting logic for it.
    def potholes
      if params[:sort_by] == "score"
        @complaints = @city.complaints.potholes.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.potholes.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.potholes
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.potholes.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.potholes.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.potholes.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.potholes.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
  # Below - Page for water Complaints and sorting logic for it.
    def water
      if params[:sort_by] == "score"
        @complaints = @city.complaints.water.sort_by { |c| c.score }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "date"
        @complaints = @city.complaints.water.order('created_at DESC')
        render action: :index
      elsif params[:sort_by] == "title"
        complaints_array = @city.complaints.water
        @complaints = complaints_array.sort_by { |com| com.title.downcase }
        render action: :index
      elsif params[:sort_by] == "comments"
        @complaints = @city.complaints.water.sort_by{ |com| com.comments.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "endorsements"
        @complaints = @city.complaints.water.sort_by{ |com| com.votes_for.size }
        @complaints.reverse!
        render action: :index
      elsif params[:sort_by] == "trending"
        @complaints = @city.complaints.water.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      else 
        @complaints = @city.complaints.water.sort_by { |com| com.hits }
        @complaints.reverse!
        render action: :index
      end
    end 
    
# End - Complaint Category Pages and Sorting Logic
   
# Begin - Complaint Process of verifying, pending, filing, and completion. Complaint Vote THresholds and Updates.
  # Below - Allows a complaint to be verified by a single upvote of the complaint from another user.
  def complaint_verification 
    if @complaint.verifying? && @complaint.votes_for.size === 1   # Checks if complaints' verifying attribute is true.
      @complaint.verifying = false                         # Sets the complaints' verification attribute to false, then:
      @complaint.pending = true                            # Sets the complaints' pending attribute to true, then.
      @complaint.verified_at = Time.current                # Sets the complaints' verified on attribute to current time.
      @complaint.verified_by_user_id = current_user.id     # Sets the complaints' verified_by attribute to user who is voting
      # Begin - The complaint is saved and has updated to pending and above changes are applied, returning true to upvote.
      if @complaint.save
        return true                                        # Returns true to the upvote.
      end 
      # End - The complaint is saved and has updated to pending and above changes are applied, returning true to upvote.
    else  # Complaint has already been verified.
      return false                                         # Returns false to the upvote.                                   
    end   # End - If statement checking if the complaint has been verified.
  end     # End of Complaint Verification method. 
 
  # Begin - Method for updating vote percentage.
  def update_complaint_vote_percentage
    if @city.users.size > 0
      complaint_votes = @complaint.cached_votes_up.to_f         # How many votes the complaint has from field attribute in Complaints, :cached_votes_up.
      city_users = @city.users.size.to_f                        # How many users the city has.
      vote_percentage =  complaint_votes / city_users           # Finds the percentage of votes to users.
      @complaint.vote_threshold = vote_percentage               # Sets the percentage threshold to the complaints :vote_threshold.
    end 
  end 
  # End - Method for updating vote percentage.
  
  # Begin - Tests the complaints' threshold being hit, which is a certain amount of votes, before being filed and sent to the city.
  def complaint_vote_threshold
    # Begin  - Checks the stage of the ecomplaint to ensure it hasn't yet started scoring and ensures it's pending.
    if @complaint.stage == 0 && @complaint.pending?
      puts "stage: #{@complaint.stage} and pending?: #{@complaint.pending}"
      # Begin - Complaint checking the threshold and progressing into the new pending stage.
      if @complaint.votes_for.count == 5        # At least 10 users voted for complaint, then: 
       # Begin - Updating of pending, filed, filed time, and stage.
        @complaint.pending = false              # Sets the complaints' pending boolean to false.
        @complaint.filed = true                 # Sets the complaints' filed boolean to true.
        @complaint.filed_at = Time.current      # Sets the complaints' current time to the filed_at attribute.
        @complaint.stage = 1                    # Sets the Complaint to first stage.
       # End - Updating of pending, filed, filed time, and stage.
        # Begin - The complaint is saved and has hit the threshold %.
        if @complaint.save
          puts "vote threshold: #{@complaint.vote_threshold} and pending?: #{@complaint.pending} and filed? #{@complaint.filed} and filed time: #{@complaint.filed_at} and stage: #{@complaint.stage}"
          CityMailer.complaint_filed_email(@city, @complaint).deliver_now   # Delivers an email to the city (mailers/city_mailer.rb). The email is in: (views/city_mailer/complaint_filed_email.html.erb).
          return true
        end 
        # End - The complaint is saved and has hit the threshold %.
      else
        return false
      end # End - Complaint checking the threshold.
      
    else  # Complaint stage is past 0 or complaint is not pending, meaning the complaint is verifying still or past the pending stage.
      #flash[:warning] = "Complaint Votes: #{@complaint.votes_for.size}. Percentage of votes: #{@vote_threshold}"
      #redirect_to city_complaints_path and return
      puts "Complaint is past stage 0 or complaint is not pending. stage: #{@complaint.stage} and pending: #{@complaint.pending}."
      return false
    end   # End - Stage and pending check.
  end   # End - Complaint Vote Threshold Method.
# End - Complaint Process of verifying, pending, filing, and completion. Complaint Vote THresholds and Updates.
  
# Begin - Acts_as_votable Controller methods for Complaints.
  # Begin - Sets up upvote method.
  def upvote 
    # Before action that Finds Complaint ID. Before action that finds city for complaint.
    # Begin - If statement to check for first if the user is a guest or user voting on their own complaint or not.
    if is_guest? 
      flash[:alert] = "You must join Ossemble to endorse this #{@complaint.city.name} Complaint."
      cookies[:stored_location] = city_complaint_path(@city, @complaint)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      if @complaint.user != current_user            # User who is voting for the complaint is not the user who created it.     
        # Begin - If statement for determining if user has already voted for complaint or not.
        if current_user.voted_for? @complaint       # Checks for :true if user has already voted for complaint. Goes to Else if user has not yet voted for complaint.
          # Below - User has not yet voted for complaint and user has not posted the complaint they're voting for.
          flash[:warning] = "You have already endorsed this #{@complaint.title} complaint for #{@city.name}, posted by #{@complaint.user.name}"
          redirect_to request.referrer
        else # User is voting on the complaint for the first time since the If statement came back as :false and it isn't the user's own complaint..
          authorize @complaint                          # Ensures user belongs to this complaints' city
           # Below - User has passed both if statments to successfully vote for the complaint.
          @complaint.upvote_by current_user               # Commits the upvote to the current user voting, then checks complaints' process.
          if @complaint.save                              # User successfully votes for complaint.
            Notification.create(recipient: @complaint.user, actor: current_user, action: "endorsed", notifiable: @complaint)
            #upgrade_badge(current_user,"Gratitude",5)     # upgrade gratitude badge for current user
            #upgrade_badge(@complaint.user,"Communication",10)  # upgrade communication badge for complaint user
            # Below - Adds to a users activity stream when endorsing a complaint and assigns recipient to the owner of the complaint.
            @complaint.create_activity :upvote, owner: current_user, recipient: @complaint.user
          # Begin - Sets up the complaints' :vote_threshold percentage after a upvote is committed. 
            update_complaint_vote_percentage 
          # End - Sets up the complaints' :vote_threshold percentage after a upvote is committed. 
            # Begin - After the upvote is put through, the upvote is checked for if it needs to be verified. Elsif below to check for threshold if Verification proves false.
            if complaint_verification                     # Checks if Complaint has yet been verified.
            # Goes to complaint_verification method above to set
              # Begin - Complaint verification process succeeds and the complaint gets saved and verified.
              if @complaint.save
                Notification.create(recipient: @complaint.user, actor: current_user, action: "confirmed", notifiable: @complaint)
                @complaint.punches.create(hits: 3)              # Adds 3 to trending counter when complaint is verified.
                flash[:notice] = "You have successfully endorsed and confirmed this #{@complaint.title} complaint for #{@city.name}, posted by<a style='color: #3c763d !important' href='/users/#{@complaint.user.slug}'>#{@complaint.user.name}</a>"
                redirect_to request.referrer
              end   
              # End - Complaint verification process succeeds and the complaint gets saved and verified.
            # Begin - Complaint checking the threshold and progressing into the new pending stage. 
            elsif complaint_vote_threshold                      # Checks if complaint has hit the voting threshold.
            # Goes to complaint_vote_threshold method above to set pending to false, stage to 1, filed to true, and filed_at to current time.
              if @complaint.save
                Notification.create(recipient: @complaint.user, actor: current_user, action: "filed", notifiable: @complaint)
                @complaint.punches.create(hits: 4)              # Adds 8 to trending counter when complaint is filed.
                flash[:notice] = "This #{@complaint.title} complaint has been endorsed enough to be filed and officially addressed to the city of #{@city.name}"
                puts "Vote Threshold: #{@vote_threshold} and Pending: #{@complaint.pending} and Filed: #{@complaint.filed} and Filed Time: #{@complaint.filed_at} and Stage: #{@complaint.stage}"
                redirect_to request.referrer
              end   
            # End - Complaint checking the threshold and progressing into the new pending stage.
            else # The Complaint is neither in verifying or filed process.
              if @complaint.save
                 Notification.create(recipient: @complaint.user, actor: current_user, action: "endorsed", notifiable: @complaint)
                @complaint.punches.create(hits: 1)              # Adds 1 to trending counter when complaint is upvoted.
                flash[:notice] = "You have successfully endorsed this #{@complaint.title} complaint for #{@city.name}, posted by #{@complaint.user.name}"
                redirect_to request.referrer
              end
            end 
            # End - After the upvote is put through, the upvote is checked for if it needs to be verified. 
          else  # For some reason, user couldn't vote for complaint.
            flash[:alert] = "Could not endorse this #{@complaint.title} complaint for #{@city.name}"
            redirect_to request.referrer
          end   # End - If statement of user voting for complaint.
        end   # End - If statement for determining if user has already voted for complaint or not.
      else  # User who is voting for the complaint is the user who created the complaint.
        flash[:alert] = "You cannot endorse your own complaint."
        redirect_to request.referrer
      end  # End - If statement to check for user voting on their own complaint or not.
    end # End - Guest Check
  end   # End - Sets up upvote method.
# End - Acts_as_votable Controller methods for Complaints.
  
# Begin - City Actions for Complaints, including Replied, PLanned, and Completed.
  
  # Below - Method for city admins to reply and acknowledge a complaint and increase it's score by 5 and changing its :replied boolean to true.
  def replied
    # Finds Complaint ID
    if current_admin # Makes sure an admin is doing replied action.
      @admin = current_admin 
      @city = City.friendly.find(params[:city_id])
      if @admin.city == @city # Admin city check and is the admin of the city so complaint replied progresses.
        if @complaint.replied == false && @complaint.verifying == false    # If complaint has not been replied to yet and is not verifying then:
          # Begin - CHeck inside of replied and and verifying if the complaint is marked completed or has failed.
          if @complaint.finished?          # Checks if Complaint has either failed or completed so the city can't acknowledge. 
            if @complaint.failed?  
              flash[:warning] = "This #{@complaint.title} complaint has already failed with a score of #{@complaint.score}%. If you're still interested in addressing this complaint, an Ossemble City Pro plan will allow you to increase its score by reopening the complaint."
            else 
              flash[:warning] = "This #{@complaint.title} complaint has already completed with a score of #{@complaint.score}%."
            end
            redirect_to request.referrer                              # Go to POST and then refresh current page by going back.
          else # Complaint is not completed or has failed. Goes onto carry out replied action.
            @complaint.replied = true                                 # Sets the :replied boolean to true.
            @complaint.score = @complaint.score + 5                   # Adds 5 to the score when the City Replies (acknowledges) complaint.
            @complaint.replied_at = Time.current                      # Fills in :replied_at attribute with the current time the city replied, then:
            
            # Begin - Complaint Replied successfully and saved.
            if @complaint.save                                       # Saves and commits to Database, then:
              # Displays a successful flash message alerting admin they replied to a plan and increased its score.
              @complaint.punches.create(hits: 7)                      # Adds 7 to trending counter when complaint is replied by the city.
              # Below - Adds an replied activity to complaint (views/public_activity/complaint/_replied).
              @complaint.create_activity :replied, owner: current_admin.city_user, recipient: @complaint.user 
              respond_to do |format|
                format.html do 
                  flash[:notice] = "You have successfully acknowledged this #{@complaint.title} complaint and increased its score by 5%. This complaint is currently at #{@complaint.score}%."
                  redirect_to request.referrer                            # Go to POST and then refresh current page by going back.
                end # End - HTML do block
                format.js # Renders AJAX replied.js.erb
              end # ENd - Respond to do block
            else # Replied failed. Complaint could not be saved and has failed for some reason, displaying the flash message below:
              flash[:alert] = "Your acknowledgement of this #{@complaint.title} complaint has not saved for some reason. Please <a style='color: #dc3545 !important' href='#{contact_us_path}'>contact us</a>."
              redirect_to request.referrer
            end  # End - Complaint Replied successfully and saved.  
          end   # End - CHeck inside of replied and and verifying if the complaint is marked completed or has failed.
        elsif @complaint.replied?   # If the Complaints' :replied boolean is already == true.
          flash[:warning] = "This #{@complaint.title} complaint has already been acknowledged."
          redirect_to request.referrer
        elsif @complaint.verifying?   # If the Complaints' :replied boolean is already == true.
          flash[:warning] = "This #{@complaint.title} complaint is still awaiting verification before it can be acknowledge. Please check back later."
          redirect_to request.referrer
        end # End - Complaint Replied check & verifying check.
      else # Is not the admin of the city
        flash[:alert] = "You have to be the admin of this city to interact with a complaint."
        redirect_to request.referrer
      end # Of admin city check
    end # Of current admin check
  end   # End - City Replied Method.
  
  # Below - Method for city admins to submit a plan for a complaint and increase it's score by 15 and changing its :planned boolean to true.
  def plan_submit
    # Finds Complaint ID
    if current_admin # Makes sure an admin is doing plan submit action.
      @admin = current_admin 
      @city = City.friendly.find(params[:city_id])
      if @admin.city == @city # Admin city check and is the admin of the city so complaint plan submit progresses.
        if @complaint.planned == false && @complaint.verifying == false && @complaint.pending == false && @complaint.stage != 0                         # If complaint has not had a plan yet then:
          @complaint.planned = true                                 # Set the Complaints' planned boolean to true then:
          @complaint.score = @complaint.score + 15                  # Add 15 points to Complaints' score, then:
          @complaint.planned_at = Time.now                          # Fills in :planned_at attribute with the current time the city submitted a plan, then:
          if @complaint.save                                        # Save the Complaint and then:
            # Displays a successful flash message alerting admin they submitted a plan and increased its score.
            @complaint.punches.create(hits: 10)                     # Adds 10 to trending counter when complaint has a plan submitted for it.
            # Below - Adds an plan submit activity to complaint (views/public_activity/complaint/_plan_submit).
            @complaint.create_activity :plan_submit, owner: current_admin.city_user, recipient: @complaint.user 
            respond_to do |format|
              format.html do 
                flash[:notice] = "You have successfully submitted a plan for this #{@complaint.title} complaint and increased its score by 15%. This complaint is currently at #{@complaint.score} %."
                redirect_to request.referrer                            # Go to POST and then refresh current page by going back.
              end # End - HTML do block
              format.js # Renders AJAX plan_submit.js.erb
            end # ENd - Respond to do block
          else # Complaint could not be saved and has failed for some reason, displaying the flash message below:
            flash[:alert] = "Your plan for this #{@complaint.title} complaint has not saved for some reason. Please <a style='color: #dc3545 !important' href='#{contact_us_path}'>contact us</a>."
            redirect_to request.referrer
          end # Of complaint planned save
        elsif @complaint.planned?            # If the Complaints' :planned boolean is already = true:
          # Displays a failure flash message for complaint already having a plan since complaint.planned == true.
          flash[:warning] = "This #{@complaint.title} complaint already has a plan submitted for it."
          redirect_to request.referrer     
        elsif @complaint.pending?            # If the Complaints' :planned boolean is already = true:
          # Displays a failure flash message for complaint already having a plan since complaint.pending == true.
          flash[:warning] = "This #{@complaint.title} complaint is still waiting for endorsements to be filed. A complaint must be filed first before it can have a plan submitted for it. Please check back later."
          redirect_to request.referrer     
        elsif @complaint.verifying?            # If the Complaints' :verifying boolean is already = true:
          # Displays a failure flash message for complaint already having a plan since complaint.verifying == true.
          flash[:warning] = "This #{@complaint.title} complaint is still waiting to be verified, and after that, to be filed. A complaint must be verified and then filed first before it can have a plan submitted for it. Please check back later."
          redirect_to request.referrer     
        elsif @complaint.finished?          # Checks if Complaint has either failed or completed so the city can't acknowledge. 
          if @complaint.failed?  
            flash[:warning] = "This #{@complaint.title} complaint has already failed with a score of #{@complaint.score}%. If you're still interested in addressing this complaint, an Ossemble City Pro plan will allow you to increase its score by reopening the complaint."
          else 
            flash[:warning] = "This #{@complaint.title} complaint has already completed with a score of #{@complaint.score}%."
          end
          redirect_to request.referrer                              # Go to POST and then refresh current page by going back.
        else 
          flash[:alert] = "Your plan for this #{@complaint.title} complaint has not been submitted for some reason. Please <a style='color: #dc3545 !important' href='#{contact_us_path}'>contact us</a>."
          redirect_to request.referrer
        end 
      else # Is not the admin of the city
        flash[:alert] = "You have to be the admin of this city to interact with a complaint."
        redirect_to request.referrer
      end # Of admin city check 
    end # Of current admin check
  end # End - City Replied Method.
  
  # Below - Method for City Admins to Complete a Complaint and lock in the score, depending on stage for bonus score.
  def completed
    if current_admin # Makes sure an admin is doing completed action.
      @admin = current_admin 
      @city = City.friendly.find(params[:city_id])
      if @admin.city == @city # Admin city check and is the admin of the city so complaint completed progresses.
        # Begin - Complaint finished, Filed and Pending check.
        if @complaint.stage != 4 && @complaint.verifying == false && @complaint.pending == false # Complaint is no longer in verification, has not failed, and is not completed.
          # Below - Updates the Complaint as completed with corresponding field attributes and assigns the score according to stages.
          @complaint.completed = true                   # Sets the complaint to :completed boolean true.
          @complaint.completed_at = Time.current        # Sets the complaint :completed_at to current time.
          @complaint.days_left = 0                      # Sets the days left of a completed complaint to 0.
          @complaint.stage = 4                          # Sets the stage to 4 to throw in with finished.
          @complaint.pending = false if @complaint.pending? 
          @complaint.filed = false if @complaint.filed? 
        # Begin - If statements detemermining what type of completion the complaint is in when marked complete by the city.
          if @complaint.save
            # Below - Adds a completed activity to complaint (views/public_activity/complaint/_completed).
            @complaint.create_activity :completed, owner: current_admin.city_user, recipient: @complaint.user 
            @reported_days =  (Time.now - @complaint.filed_at)/1.day
            respond_to do |format|
              format.html do 
                flash[:notice] = "You have successfully marked this #{@complaint.title} complaint completed. It was addressed within #{ @reported_days.round(1) } days since it was filed. This complaint has finished with the score of #{@complaint.score} %."
                redirect_to request.referrer   # Go to POST and then refresh current page by going back.
              end # End - HTML do block
              format.js # Renders AJAX completed.js.erb
            end # End - Respond to do block
          else # Complaint did not save for some reason and displays following flash message warning:
            flash[:alert] = "This #{@complaint.title} complaint could not be completed for some reason. Please contact us."
            redirect_to request.referrer
          end
        # End - If statements detemermining what type of completion the complaint is in when marked complete by the city.
        elsif @complaint.verifying?   # Complaint's :verifying boolean is true, then it can't be completed.
          # Flash message saying the complaint is still verifying so it cannot be completed.
          flash[:warning] = "This #{@complaint.title} complaint is still in the verification process. "
          redirect_to request.referrer
        elsif @complaint.pending?
          flash[:warning] = "This #{@complaint.title} complaint has not yet been filed. Please wait until the CAC is sent and the complaint receives enough endorsements to be filed."
          redirect_to request.referrer
        elsif @complaint.failed?
          flash[:warning] = "This #{@complaint.title} complaint has already run out of time for its deadline and has failed to be addressed. Having a Pro subscription with Ossemble would allow you to reopen this complaint, address it, and to increase its score. "
          redirect_to request.referrer
        elsif @complaint.completed?  # Complaint's :completed boolean is true, then it's already completed.
          flash[:warning] = "This #{@complaint.title} complaint has already been deemed complete."
          redirect_to request.referrer
        end # End - If statement for determing :completed being false and :verifying being false.

      else # Is not the admin of the city
        flash[:alert] = "You have to be the admin of this city to interact with a complaint."
        redirect_to request.referrer
      end # Of admin city check
    end # Of current admin check
  end   # End - Completed if Statement.
# End - City Actions for Complaints, including Replied, PLanned, and Completed.
  
  private
    
  # Sets the Complaint params ID
    def set_complaint
      @complaint = Complaint.friendly.find(params[:id])
    end
    
  # Below - Permitted Params in the creation of a Complaint. 
    def complaint_params
      params.require(:complaint).permit(:address, :description, :complaint_category_id, :complaint_score_id, :latitude, :longitude, :title, :image)
    end
    # Below - Finds and sets user and city for edit, update and destroy.
    def set_user_and_city
      @user = User.find(params[:user_id])
      @city_complaint = @complaint.city_id
      @city = City.find @city_complaint
    end
    # Sets the CIty Params for Complaint on Index, New and Create.
    def set_city 
      @city = City.friendly.find(params[:city_id])
    end
    
end # End - Complaint Controller.
