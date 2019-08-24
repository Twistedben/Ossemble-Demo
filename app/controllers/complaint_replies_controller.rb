class ComplaintRepliesController < ApplicationController
# Main controller for admin action that interacts with Complaint by reokying to a complaint
  # Below - Before action that sets complaint and the city.
  before_action :set_complaint_and_city
  # Below - Before action that find admin and admin's slave user.
  before_action :set_admin_and_slave
  # Below - Before action that ensures admin can only access their dashboard.
  before_action :authorize_city_admin

  def new
    #if current_admin #Ensures is an admin
    @complaint_reply = ComplaintReply.new
      respond_to do |format| 
        format.js  #Renders new.js.erb file in complaint_replies
      end 
   # end 
  end

  def create
    @complaint_reply = @complaint.complaint_reply.build(reply_params)
  end

  def edit
  end

  def update
  end

  def destroy
  end
  
  private 
  
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
  
  # Below -  Sets city and complaint from url
  def set_complaint_and_city
    @city = City.friendly.find(params[:city_id])
    @complaint = Complaint.friendly.find(params[:complaint_id])
  end   
  
  # Below -  
  def reply_params
    params.require(:complaint_reply).permit(:user_id, :complaint_id, :description)
  end   
  
  # Below - Sets admin and slave from admin
  def set_admin_and_slave
    @admin = current_admin 
    @slave_user = current_admin.city_user
  end 
  # Below - Ensures the admin belongs to the city they're on.
  def authorize_city_admin
    if @admin.city == current_admin.city
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

