class ComplaintPlansController < ApplicationController
# Main controller for admin action that interacts with Complaint by submitting a plan
  # Below - Before action that sets complaint and the city.
  before_action :set_complaint_and_city
  # Below - Before action that find admin and admin's slave user.
  before_action :set_admin_and_slave
  # Below - Before action that ensures admin can only access their dashboard.
  before_action :authorize_city_admin

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private 
  
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

  # Below -  Sets city and complaint from url
  def set_complaint_and_city
    @city = City.friendly.find(params[:city_id])
    @complaint = Complaint.friendly.find(params[:id])
  end   
  
  # Below - Sets admin and slave from admin
  def set_admin_and_slave
    @admin = current_admin 
    @slave_user = current_admin.city_user
  end 
  # Below - Ensures the admin belongs to the city they're on.
  def authorize_city_admin
    if @admin.city == current_admin.city && @admin == current_admin
    else 
      if current_admin 
        flash[:alert] = "You need to be the Admin of that city to access that page!"
        redirect_to institute_admin_path(current_admin.institute, current_admin)
      else
        flash[:alert] = "You need to be have an admin City Profile to access that page!"
        redirect_to new_admin_sessions_path
      end 
    end
  end   

end
