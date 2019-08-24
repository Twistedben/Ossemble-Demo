class PetitionsController < OssemblyController
  # Below - Sets the singular petition instance variable.
  before_action :set_petition, only: [:show, :edit, :update, :destroy, :plan_submit, :replied, :completed, :upvote ]
  # Below - Finds the current City ID associated with petitions.
  before_action :set_city, except: [:edit, :update, :destroy]
  # Below - Before action that finds user and city.
  before_action :set_user_and_city, only: [:edit, :update, :destroy]
  # Below - Before_action that sets the instance variables for topics and subtopics filter panel.
  before_action :set_topics

  
  def index
  # Begin - Sorting logic for all petitions. 
    if params[:sort_by] == "date"
      @petitions = @city.petitions.order('created_at DESC')
    elsif params[:sort_by] == "title"
      petitions_array = @city.petitions
      @petitions = petitions_array.sort_by { |pet| pet.title.downcase }
    elsif params[:sort_by] == "comments"
      @petitions = @city.petitions.sort_by { |pet| pet.count_comments }
      @petitions.reverse!
    elsif params[:sort_by] == "endorsements"
      @petitions = @city.petitions.sort_by { |pet| pet.votes_for.size }
      @petitions.reverse!
    elsif params[:sort_by] == "trending"
      @petitions = @city.petitions.sort_by { |pet| pet.hits }
      @petitions.reverse!
    else 
      @petitions = @city.petitions.sort_by { |pet| pet.hits }
      @petitions.reverse!
      @week_petitions = @city.petitions.most_hit(1.week.ago, 10)
      @month_petitions = @city.petitions.most_hit(1.month.ago, nil).offset(10)
    end
  # End - Sorting logic for all petitions.
  end

  def show
    
    # Below - WHen show page is rendered, runs the petition method to update the days left if the petition is filed.
    @petition.update_days_left if @petition.filed?
    # Below - adds punch counter to City Review for trending.
    @petition.punch(request)
    @petition_comments = @petition.comments
    # Below - Sets up sharing meta-tags for reviews.
    if @petition.image.attached?
      set_meta_tags title: @petition.title,
        site: 'Ossemble',
        description: @petition.goal, 
        keywords: @petition.description,
        image_src: url_for(@petition.image),
        twitter: {
          site: "@ossemble",
          title: @petition.title,
          description: @petition.goal,
          image: url_for(@petition.image)
        },
        og: {
          type: "website",
          title: @petition.title,
          url: city_petition_url(@city, @petition),
          description: @petition.goal,
          image: url_for(@petition.image)
        }
    else # Petition doesn't have an image
      set_meta_tags title: @petition.title,
        site: 'Ossemble',
        description: @petition.goal, 
        keywords: @petition.description,
        twitter: {
          site: "@ossemble",
          title: @petition.title,
          description: @petition.goal
        },
        og: {
          type: "website",
          title: @petition.title,
          url: city_petition_url(@city, @petition),
          description: @petition.goal
        }
    end 
  end

  def new
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to new page.
      flash[:alert] = "You must join Ossemble to submit a #{@city.name} Petition."
      cookies[:stored_location] = new_city_petition_path(@city)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      @petition = @city.petitions.new
      authorize @petition # Ensures user is signed in and not a guest
    end
  end

  def edit
    authorize @petition # Ensures user owns the petition or is a mod
  end

  def create
    @petition = @city.petitions.build(petition_params)
    # Below - Sets the user id to the current user posting the Petition
    @petition.user_id = current_user.id 
    # Below - Sets the petition score id for the petition
    @petition.petition_score_id = @city.petition_score.id 
    # Begin - If statement for determining if the Petition was committed to the DB successfully, then rendering the Petitions 
      # show page with a success message, or displaying an error and rendering a new form page.
    authorize @petition # Ensures user owns the petition or is a mod
    if @petition.save # If it saves, display Flash message success, if not move to 'else'
      # Automatically endorses the petition
      @petition.upvote_by current_user
      # Below - Adds to a users activity stream when creating a new Petition and assigns the city as the recipient of it.
      @petition.create_activity :create, owner: current_user, recipient: @petition.city
      #upgrade_badge(current_user, 'Ownership', 100) # Upgrade the ownership badge
      flash[:notice] = "Your #{@petition.title} Petition for #{@city.name} has been successfully submitted!"   # Shows a Flash message of success
      redirect_to city_petition_path(@city, @petition)  # Redirects to the Petition's show page.
    else
      flash[:alert] = "Could not submit your Petition for #{@city.name}. See why below!"   # Shows a Flash message of error
      render 'new' # Reload the New template with errors
    end # End - If statement for review creation.
  end

  def update
    authorize @petition # Ensures user owns the petition or is a mod
    if @petition.update(petition_params)
      flash[:notice] = "Your #{@petition.title} Petition for #{@petition.city.name} has been updated successfully!"
      redirect_to city_petition_path(@city, @petition)
    else 
      flash[:alert] = "Your Petition for #{@petition.city.name} could not be updated. See why below!"
      render 'edit'
    end 
  end

  def destroy
    authorize @petition # Ensures user owns the petition or is a mod
    if @petition.user === current_user # Makes sure user deleting is user
      if @petition.destroy
        flash[:notice] = "Your Petition for #{@user.city.name} has been deleted."
        redirect_to city_petitions_path(@city)
      else 
        flash[:alert] = "Your Petition for #{@user.city.name} could not be deleted for some unknown reason. Please contact us."
        render 'edit'
      end
    end
  end

# Begin - FILTER PAGES: Scoped and filter pages.
  # Below -  Pending petitions for filter panel page, to scope index down to pending petitions.
  def pending
  # Begin - Sorting logic for pending petitions. 
    if params[:sort_by] == "date"
      @petitions = @city.petitions.pending.order('created_at DESC')
      render action: :index
    elsif params[:sort_by] == "title"
      petitions_array = @city.petitions.pending
      @petitions = petitions_array.sort_by { |pet| pet.title.downcase }
      render action: :index
    elsif params[:sort_by] == "comments"
      @petitions = @city.petitions.pending.sort_by { |pet| pet.count_comments }
      @petitions.reverse!
      render action: :index
    elsif params[:sort_by] == "endorsements"
      @petitions = @city.petitions.pending.sort_by { |pet| pet.votes_for.size }
      @petitions.reverse!
      render action: :index
    elsif params[:sort_by] == "trending"
      @petitions = @city.petitions.pending.sort_by { |pet| pet.hits }
      @petitions.reverse!
      render action: :index
    else 
      @petitions = @city.petitions.pending.sort_by { |pet| pet.hits }
      @petitions.reverse!
      render action: :index
    end
  # End - Sorting logic for pending petitions.
  end   

  # Below -  Filed petitions for filter panel page, to scope index down to filed petitions.
  def filed
  # Begin - Sorting logic for filed petitions. 
    if params[:sort_by] == "date"
      @petitions = @city.petitions.filed.order('created_at DESC')
      render action: :index
    elsif params[:sort_by] == "title"
      petitions_array = @city.petitions.filed
      @petitions = petitions_array.sort_by { |pet| pet.title.downcase }
      render action: :index
    elsif params[:sort_by] == "comments"
      @petitions = @city.petitions.filed.sort_by { |pet| pet.count_comments }
      @petitions.reverse!
      render action: :index
    elsif params[:sort_by] == "endorsements"
      @petitions = @city.petitions.filed.sort_by { |pet| pet.votes_for.size }
      @petitions.reverse!
      render action: :index
    elsif params[:sort_by] == "trending"
      @petitions = @city.petitions.filed.sort_by { |pet| pet.hits }
      @petitions.reverse!
      render action: :index
    elsif params[:sort_by] == "date-f"
      @petitions = @city.petitions.filed.order('filed_at DESC')
      render action: :index
    else 
      @petitions = @city.petitions.filed.sort_by { |pet| pet.hits }
      @petitions.reverse!
      render action: :index
    end
  # End - Sorting logic for filed petitions.
  end   
  
  # Below -  Finished petitions for filter panel page, to scope index down to finished petitions.
  def finished
  # Begin - Sorting logic for finished petitions. 
    if params[:sort_by] == "date"
      @petitions = @city.petitions.finished.order('created_at DESC')
      render action: :index
    elsif params[:sort_by] == "title"
      petitions_array = @city.petitions.finished
      @petitions = petitions_array.sort_by { |pet| pet.title.downcase }
      render action: :index
    elsif params[:sort_by] == "comments"
      @petitions = @city.petitions.finished.sort_by { |pet| pet.count_comments }
      @petitions.reverse!
      render action: :index
    elsif params[:sort_by] == "endorsements"
      @petitions = @city.petitions.finished.sort_by { |pet| pet.votes_for.size }
      @petitions.reverse!
      render action: :index
    elsif params[:sort_by] == "trending"
      @petitions = @city.petitions.finished.sort_by { |pet| pet.hits }
      @petitions.reverse!
      render action: :index
    elsif params[:sort_by] == "date-f"
      @petitions = @city.petitions.finished.order('finished_at DESC')
      render action: :index
    else 
      @petitions = @city.petitions.finished.sort_by { |pet| pet.hits }
      @petitions.reverse!
      render action: :index
    end
  # End - Sorting logic for finished petitions.
  end   
  
# End - FILTER PAGES: Scoped and filter pages.
  
# Begin - Acts_as_votable Controller methods for petitions.
  # Begin - Sets up upvote method.
  def upvote 
    # Before action that Finds petition ID. Before action that finds city for petition.
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to show page.
      flash[:alert] = "You must create an account and join #{@petition.city.name} to Sign this Petition."
      cookies[:stored_location] = city_petition_path(@city, @petition)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      # Begin - If statement for determining if user has already voted for petition or not.
      if current_user.voted_for? @petition       # Checks for :true if user has already voted for petition. Goes to Else if user has not yet voted for petition.
        # Below - User has not yet voted for petition and user has not posted the petition they're voting for.
        flash[:warning] = "You have already signed this #{@petition.title} petition for #{@city.name}, posted by<a style='color: #3c763d !important' href='/users/#{@petition.user.slug}'>#{@petition.user.name}</a>"
        redirect_to request.referrer
      else # User is voting on the petition for the first time since the If statement came back as :false and it isn't the user's own petition..
        authorize @petition                          # Ensures user belongs to this petitions' city
        # Below - User has passed both if statments to successfully vote for the petition.
        @petition.upvote_by current_user               # Commits the upvote to the current user voting, then checks petitions' process.
        if @petition.save                              # User successfully votes for petition.
          Notification.create(recipient: @petition.user, actor: current_user, action: "endorsed", notifiable: @petition) 
          #upgrade_badge(current_user,"Gratitude",5)     # upgrade gratitude badge for current user
          #upgrade_badge(@petition.user,"Communication",10)  # upgrade communication badge for complaint user
          # Below - Adds to a users activity stream when endorsing a petition and assigns recipient to the owner of the petition.
          @petition.create_activity :upvote, owner: current_user, recipient: @petition.user
          if @petition.vote_threshold                     # Checks if petition has hit the signature goal threshold of 100, method is in petition.rb model.
            # Begin -  Petition just hit threshold and email was sent to city.
            if @petition.save
              @petition.punches.create(hits: 4)              # Adds 3 to trending counter when petition is verified.
              CityMailer.petition_filed_email(@city, @petition).deliver_now   # Delivers an email to the city (mailers/city_mailer.rb). The email is in: (views/city_mailer/complaint_filed_email.html.erb).
              # Below - Includes more info than just city when filed and has recipients attached in FLash and delivers email to additional recipients or just one recipient.
              if @petition.recipient? && @petition.additional_recipient.empty? # Sends email to just recipient
                flash[:notice] = "This #{@petition.title} petition has accumulated enough signatures to be filed and officially sent, addressed to the city of #{@petition.city.name} and #{@petition.recipient_slug}."
                CityMailer.recipient_petition_email(@city, @petition, @petition.recipient).deliver_now   # Delivers an email to the additional recipient and third. CHecks if additional exists inside city_mailer: (mailers/city_mailer.rb). The email is in: (views/city_mailer/additional_petition_email.html.erb).
              elsif @petition.recipient? && @petition.additional_recipient? # Sends emails to recipient and additional recipient
                flash[:notice] = "This #{@petition.title} petition has accumulated enough signatures to be filed and officially sent, addressed to the city of #{@petition.city.name}, #{@petition.recipient_slug}, and #{@petition.additional_recipient_slug}."
                CityMailer.recipient_petition_email(@city, @petition, @petition.recipient).deliver_now   # Delivers an email to recipient. city_mailer: (mailers/city_mailer.rb). The email is in: (views/city_mailer/recipient_petition_email.html.erb).
                CityMailer.additional_petition_email(@city, @petition, @petition.additional_recipient).deliver_now   # Delivers an email to the additional recipient and third. CHecks if additional exists inside city_mailer: (mailers/city_mailer.rb). The email is in: (views/city_mailer/additional_petition_email.html.erb).
              else # Goes only to city 
                flash[:notice] = "This #{@petition.title} petition has accumulated enough signatures to be filed and officially sent, addressed to the city of #{@petition.city.name}."
              end 
              redirect_to request.referrer
            end # End - Petition just hit threshold and email was sent to city.
          else # The petition is either above or below vote threshold.
            if @petition.save
              @petition.punches.create(hits: 1)              # Adds 1 to trending counter when petition is upvoted.
              if @petition.filed?   # Checks if petition has been filed, showing a different flash message.
                flash[:notice] = "You have successfully signed this #{@petition.title} petition for #{@city.name}, posted by<a style='color: #3c763d !important' href='/users/#{@petition.user.slug}'>#{@petition.user.name}</a>. It has already been filed and sent to #{@city.name}."
              else  # Petition has not been filed.
                flash[:notice] = "You have successfully signed this #{@petition.title} petition for #{@city.name}, posted by<a style='color: #3c763d !important' href='/users/#{@petition.user.slug}'>#{@petition.user.name}</a>. Its goal percentage is currently at #{@petition.vote_percentage} and #{@petition.votes_needed} signatures are still needed."
              end  # End - Flash message change depending on if petition has been filed or not.
              redirect_to request.referrer
            end # End - Normal vote petition save.
          end # End - Vote threshold check of petition.
        else  # For some reason, user couldn't vote for petition.
          flash[:alert] = "Could not sign this #{@petition.title} petition for #{@city.name}. Please contact us."
          redirect_to request.referrer
        end   # End - If statement of user voting for petition.
      end   # End - If statement for determining if user has already voted for petition or not.
    end
  end   
  # End - Sets up upvote method.
# End - Acts_as_votable Controller methods for petitions.
  
# Begin - City Actions for petitions, including Replied, PLanned, and Completed.
  
  # Below - Method for city admins to reply and acknowledge a petition and increase it's score by 5 and changing its :replied boolean to true.
  def replied
    # Finds petition ID
    if current_admin # Makes sure an admin is doing replied action.
      @admin = current_admin 
      @city = City.friendly.find(params[:city_id])
      if @admin.city == @city # Admin city check and is the admin of the city so petition replied progresses.
        if @petition.replied == false     # If petition has not been replied to yet:
          # Begin - CHeck inside of replied and and verifying if the petition is marked completed or has failed.
          if @petition.finished?          # Checks if petition has either failed or completed so the city can't acknowledge. 
            if @petition.failed?  
              flash[:warning] = "This #{@petition.title} petition has already failed."
            else 
              flash[:warning] = "This #{@petition.title} petition has already completed."
            end
            redirect_to request.referrer                              # Go to POST and then refresh current page by going back.
          else # petition is not completed or has failed. Goes onto carry out replied action.
            @petition.replied     = true                                 # Sets the :replied boolean to true.
            @petition.score       = @petition.score + 5                   # Adds 5 to the score when the City Replies (acknowledges) petition.
            @petition.replied_at  = Time.current                      # Fills in :replied_at attribute with the current time the city replied, then:
            @petition.days_left   = 0                                # Sets days left to 0
            @petition.stage       = 4                                # Sets stage to 4 meaning the city replied or responded, stoping the timer
            # Begin - petition Replied successfully and saved.
            if @petition.save                                       # Saves and commits to Database, then:
              # Displays a successful flash message alerting admin they replied to a plan and increased its score.
              @petition.punches.create(hits: 7)                      # Adds 7 to trending counter when petition is replied by the city.
              # Below - Adds an replied activity to petition (views/public_activity/petition/_replied).
              @petition.create_activity :replied, owner: current_admin.city_user, recipient: @petition.user 
              respond_to do |format|
                format.html do 
                  flash[:notice] = "You have successfully acknowledged this #{@petition.title} petition and increased its score by 5%. This petition is currently at #{@petition.score}%."
                  redirect_to request.referrer                            # Go to POST and then refresh current page by going back.
                end # End - HTML do block
                format.js # Renders AJAX replied.js.erb
              end # ENd - Respond to do block
            else # Replied failed. petition could not be saved and has failed for some reason, displaying the flash message below:
              flash[:alert] = "Your acknowledgement of this #{@petition.title} petition has not saved for some reason. Please <a style='color: #dc3545 !important' href='#{contact_us_path}'>contact us</a>."
              redirect_to request.referrer
            end  # End - petition Replied successfully and saved.  
          end   # End - CHeck inside of replied and and verifying if the petition is marked completed or has failed.
        elsif @petition.replied?   # If the petitions' :replied boolean is already == true.
          flash[:warning] = "This #{@petition.title} petition has already been acknowledged."
          redirect_to request.referrer
        elsif @petition.verifying?   # If the petitions' :replied boolean is already == true.
          flash[:warning] = "This #{@petition.title} petition is still awaiting verification before it can be acknowledge. Please check back later."
          redirect_to request.referrer
        end # End - petition Replied check & verifying check.
      else # Is not the admin of the city
        flash[:alert] = "You have to be the admin of this city to interact with a petition."
        redirect_to request.referrer
      end # Of admin city check
    end # Of current admin check
  end   # End - City Replied Method.
  
  # Below - Method for city admins to submit a plan for a petition and increase it's score by 15 and changing its :planned boolean to true.
  def plan_submit
    # Finds petition ID
    if current_admin # Makes sure an admin is doing plan submit action.
      @admin = current_admin 
      @city = City.friendly.find(params[:city_id])
      if @admin.city == @city # Admin city check and is the admin of the city so petition plan submit progresses.
        if @petition.planned == false && @petition.pending == false      # If petition has not had a plan yet then:
          @petition.planned     = true                                 # Set the petitions' planned boolean to true then:
          @petition.score       = @petition.score + 15                  # Add 15 points to petitions' score, then:
          @petition.planned_at  = Time.now                          # Fills in :planned_at attribute with the current time the city submitted a plan, then:
          @petition.days_left   = 0                                # Sets days left to 0
          @petition.stage       = 4                                # Sets stage to 4 meaning the city replied or responded, stoping the timer

          if @petition.save                                        # Save the petition and then:
            # Displays a successful flash message alerting admin they submitted a plan and increased its score.
            @petition.punches.create(hits: 10)                     # Adds 10 to trending counter when petition has a plan submitted for it.
            # Below - Adds an plan submit activity to petition (views/public_activity/petition/_plan_submit).
            @petition.create_activity :plan_submit, owner: current_admin.city_user, recipient: @petition.user 
            respond_to do |format|
              format.html do 
                flash[:notice] = "You have successfully submitted a plan for this #{@petition.title} petition and increased its score by 15%. This petition is currently at #{@petition.score} %."
                redirect_to request.referrer                            # Go to POST and then refresh current page by going back.
              end # End - HTML do block
              format.js # Renders AJAX plan_submit.js.erb
            end # ENd - Respond to do block
          else # petition could not be saved and has failed for some reason, displaying the flash message below:
            flash[:alert] = "Your plan for this #{@petition.title} petition has not saved for some reason. Please <a style='color: #dc3545 !important' href='#{contact_us_path}'>contact us</a>."
            redirect_to request.referrer
          end # Of petition planned save
        elsif @petition.planned?            # If the petitions' :planned boolean is already = true:
          # Displays a failure flash message for petition already having a plan since petition.planned == true.
          flash[:warning] = "This #{@petition.title} petition already has a plan submitted for it."
          redirect_to request.referrer     
        elsif @petition.pending?            # If the petitions' :planned boolean is already = true:
          # Displays a failure flash message for petition already having a plan since petition.pending == true.
          flash[:warning] = "This #{@petition.title} petition is still waiting for endorsements to be filed. A petition must be filed first before it can have a plan submitted for it. Please check back later."
          redirect_to request.referrer     
        elsif @petition.finished?          # Checks if petition has either failed or completed so the city can't acknowledge. 
          if @petition.failed?  
            flash[:warning] = "This #{@petition.title} petition has already failed with a score of #{@petition.score}%. If you're still interested in addressing this petition, an Ossemble City Pro plan will allow you to increase its score by reopening the petition."
          else 
            flash[:warning] = "This #{@petition.title} petition has already completed with a score of #{@petition.score}%."
          end
          redirect_to request.referrer                              # Go to POST and then refresh current page by going back.
        else 
          flash[:alert] = "Your plan for this #{@petition.title} petition has not been submitted for some reason. Please <a style='color: #dc3545 !important' href='#{contact_us_path}'>contact us</a>."
          redirect_to request.referrer
        end 
      else # Is not the admin of the city
        flash[:alert] = "You have to be the admin of this city to interact with a petition."
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
        if @petition.finished? == false && @petition.pending == false # Complaint is no longer in verification, has not failed, and is not completed.
          # Below - Updates the Complaint as completed with corresponding field attributes and assigns the score according to stages.
          @petition.completed = true                   # Sets the complaint to :completed boolean true.
          @petition.completed_at = Time.current        # Sets the complaint :completed_at to current time.
          @petition.days_left = 0                      # Sets the days left of a completed complaint to 0.
          @petition.stage = 5                          # Sets the stage to 4 to throw in with finished.
          @petition.pending = false if @petition.pending?
          @petition.filed = false if @petition.filed?
        # Begin - If statements detemermining what type of completion the complaint is in when marked complete by the city.
          if @petition.save
            # Below - Adds a completed activity to complaint (views/public_activity/complaint/_completed).
            @petition.create_activity :completed, owner: current_admin.city_user, recipient: @petition.user 
            @reported_days =  @petition.days_passed.to_i
            respond_to do |format|
              format.html do 
                flash[:notice] = "You have successfully marked this #{@petition.title} complaint completed. It was addressed within #{ @reported_days.round(1) } days since it was filed. This complaint has finished with the score of #{@petition.score} %."
                redirect_to request.referrer   # Go to POST and then refresh current page by going back.
              end # End - HTML do block
              format.js # Renders AJAX completed.js.erb
            end # End - Respond to do block
          else # Complaint did not save for some reason and displays following flash message warning:
            flash[:alert] = "This #{@petition.title} complaint could not be completed for some reason. #{Please contact us}."
            redirect_to request.referrer
          end
        # End - If statements detemermining what type of completion the complaint is in when marked complete by the city.
        elsif @petition.pending?
          flash[:warning] = "This #{@petition.title} complaint has not yet been filed. Please wait until the CAC is sent and the complaint receives enough endorsements to be filed."
          redirect_to request.referrer
        elsif @petition.failed?
          flash[:warning] = "This #{@petition.title} complaint has already run out of time for its deadline and has failed to be addressed. Having a Pro subscription with Ossemble would allow you to reopen this complaint, address it, and to increase its score. "
          redirect_to request.referrer
        elsif @petition.completed?  # Complaint's :completed boolean is true, then it's already completed.
          flash[:warning] = "This #{@petition.title} complaint has already been deemed complete."
          redirect_to request.referrer
        end # End - If statement for determing :completed being false and :verifying being false.

      else # Is not the admin of the city
        flash[:alert] = "You have to be the admin of this city to interact with a complaint."
        redirect_to request.referrer
      end # Of admin city check
    end # Of current admin check
  end   # End - Completed if Statement.

  
  private
    # Below - Sets singular petition from URL params
    def set_petition
      @petition = Petition.friendly.find(params[:id])
    end
    
    # Below - Finds and sets user and city for edit, update and destroy.
    def set_user_and_city
      @petition = Petition.friendly.find(params[:id])
      @user = User.friendly.find(params[:user_id])
      @city = @petition.city
    end
    
    # Below - Sets the City for Petition on Index, New and Create.
    def set_city 
      @city = City.friendly.find(params[:city_id])
    end

    # Below - Sets strong params for creation and update of a petition.
    def petition_params
      params.require(:petition).permit(:title, :goal, :description, :city_id, :user_id, :image, :file, :issues, :recipient, :additional_recipient, :recipient_slug, :additional_recipient_slug)
    end
    
end
