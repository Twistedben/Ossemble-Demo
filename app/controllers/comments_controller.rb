class CommentsController < ApplicationController
# Main controller for handling comments. 
  # Below - Finds Polymorphic association with Comment as @Commentable.
  before_action :set_commentable
  # Below - Before action finding @comment and @user for modification actions.
  before_action :set_comment_and_user, only: [:edit, :update, :destroy, :upvote, :reply]
  # Below - Devise authentication of user actions.
  #before_action :authenticate_user!
  
  def reply
    # Below - Only does Pundit authorization if it's a user
    if current_user 
      authorize @comment # Ensures user is logged in.
    end
    respond_to do |format| 
      format.js 
    end 
  end 
  
  def new
    @comment = Comment.new
    @admins = current_admin.institute.admins
  end
  
  def create
    @comment = @commentable.comments.new(comment_params)
    # Begin - Determines if the comment is a Subject COmment or a Reply and assigns parent_ids and Subjects accordingly.
    if @comment.commentable_type != "Comment"
      @comment.parent_id = @comment.commentable_id # Assigns the main comment on a subject the ID of the subject so children can inherit it.
      @comment.subject = @comment.commentable_type # Assigns the main comment on a subject the type of subject it is so children know parent type.
    else # Comment is a reply and not a initial comment 
      @comment.parent_id = @comment.commentable.parent_id # Ensures replies and children are assigned the subject's ID
      @comment.subject = @comment.commentable.subject     # Carries on the type of comments they are, IE "Post", "CityReview". 
    end
    # End - Determines if the comment is a Subject COmment or a Reply and assigns parent_ids and Subjects accordingly.
    # Below - Assigns the created comment to the user commenting. If an admin is creating comment, assigns slave user instead.
    if current_user 
      @comment.user = current_user
    elsif current_admin
      if @comment.commentable_type == "Comment" # COmment is a reply
        find_page_subject # Finds the resource being commented on so resource can be checked if it's an admin  
        if is_admin_resource?(@page) # ADmin is commenting in Workplace 
          @comment.admin = current_admin
        else # Admin is in a public feed page
          @comment.user = current_admin.city_user
        end 
      else # COmment is a new comment
        if is_admin_resource?(@commentable) # ADmin is commenting in Workplace 
          @workplace = Workplace.friendly.find(params[:workplace_id]) if params[:workplace_id]
          @admin = Admin.friendly.find(params[:admin_id]) if params[:admin_id]
          @admin = AdminLibrary.friendly.find(params[:admin_library_id]) if params[:admin_library_id]
          @comment.admin = current_admin
        else # ADmin commenting in Public User resource
         @comment.user = current_admin.city_user
        end 
      end  
    end 
    
  # Begin - Different creation process for admin and user, because admin won't go through Pundit.
    # Below - If it's a user commenting, run Pundit authorization and creation process. Otherwise, if admin, check if it's admin city then run creation process.
    if current_user       # Checks if a user is logged in
      authorize @comment  # Ensures the poster is logged in.
      save_comment        # Calls method in "private" to continue with the creation process.
    elsif current_admin   # Checks if logged in user is an admin
      save_comment      # Calls method in "private" to continue with the creation process.
    else 
      flash[:alert] = "You must be logged in to comment."
      redirect_to request.referrer
    end
  # End - Different creation process for admin and user, because admin won't go through Pundit.
  end 


  def edit
    # Before action finding comment and user (@user, @comment)
    @edit_comment = Comment.find(params[:id])
    if is_workplace_page? 
      @city = City.friendly.find(params[:institute_id])
      @admin = Admin.friendly.find(params[:admin_id])
      respond_to do |format| 
        format.js { render :file => "admins/comments/edit.js.erb" }
      end 
    else # Not a comment in an admin page
      if current_user # Checks pundit authorization only if its a logged in user. 
        authorize @edit_comment # Ensures user is owner of comment or is a mod.
        respond_to do |format| 
          format.js 
        end 
      elsif current_admin && current_admin.city_user == @edit_comment.user# Ensures the admin owns the comment they're editing.
        respond_to do |format| 
          format.js 
        end 
      else 
        flash[:alert] = "You must own a comment to edit it."
        redirect_to request.referrer
      end
    end
  end
  
  def update
    # Before action finding comment and user (@user, @comment)
    @edit_comment = Comment.find(params[:id])
    if current_user 
      authorize @edit_comment # Ensures user is owner of comment or is a mod.
      update_comment
    elsif current_admin && @edit_comment.user == current_admin.city_user # Ensures admin owns comment
      update_comment
    else 
      flash[:alert] = "You must own a comment to edit it."
      redirect_to request.referrer
    end
  end   # End - Update method.
  
  def destroy
    # Before action finding comment and user (@user, @comment)
    if current_user 
      authorize @comment # Ensures user is owner of comment or is a mod.  
    end 
    if @comment.user == current_user || @comment.user == current_admin.city_user # Makes sure owner of comment is deleting the comment
      if @comment.destroy
        # Below - Deleting a punch to the subject page to lower trending (IE: "Post, Complaint, CityReview").
        find_page_subject
        @page.punches.first.destroy
        # Below - Creates a destroy activity for a comment.
        #@comment.create_activity :destroy, owner: current_user
        respond_to do |format|
          format.html do 
          # Begin - Flash message errors changes depending on a reply or comment.
            if @comment.commentable_type == "Comment"
              flash[:notice] = "Your reply has been deleted." 
            else # Not a reply
              flash[:notice] = "Your comment has been deleted." 
            end 
          # End - Flash message changes depending on a reply or comment.     
            redirect_to request.referrer # Renders traditional page refresh if HTML
          end # End - HTML do block
        format.js # Renders AJAX comments/destroy.js.erb
        end # ENd - Respond to do block
      else  # Comment was unable to be destroyed
        # Below - Creates errors within the page for comments. Needed due to reducing error code redundancy on Subject pages.
        find_comment_errors
        if @comment.commentable_type == "Comment"
          # Below - Renders an alert, notifying the user they alrady endorsed.
          render js: "alert('This comment cannot be destroyed. Reasons: #{@errors}. Please contact us.')"
        else # Not a reply
          render js: "alert('This reply cannot be destroyed. Reasons: #{@errors} Please contact us.')"
        end 
        # End - Flash message changes depending on a reply or comment.     
        redirect_to request.referrer # Renders traditional page refresh if HTML
      end # End - If statement destroying or not destroying comment
    end # End - Current user check before destruction.
  end   # End - Destroy method
  
  # Begin - Acts_as_votable Controller method for Comments.
  def upvote 
    # Before action finding @comment and @user
    #if is_admin_resource?(@commentable) # ADmin is upvoting in Workplace 
      # Begin - Admin check for upvoting, whether admin or logged in admin.
      #authorize @comment #
      # Begin - If statement to check for admin voting on their own comment or not.
      if @comment.admin != current_admin            # Admin who is voting for the comment is not the admin who created it.     
        # Begin - If statement for determining if admin has already voted for comment or not.
        if current_admin.voted_for? @comment       # Checks for :true if admin has already voted for comment. Goes to Else if admin has not yet voted for city review.
          respond_to do |format|
            format.html do 
              # Below - Admin has not yet voted for comment and admin has not commentableed the comment they're voting for.
              flash[:warning] = "You have already endorsed this comment by #{@comment.admin.name}"
              redirect_to request.referrer
            end # End - HTML Response
            # Below - Renders an alert, notifying the user they alrady endorsed.
            render js: "alert('You have already endorsed this comment by #{@comment.admin.name}')"
            #format.js 
          end # End - Respond to block for html/js response.
        else # User is voting on the Comment for the first time.
        # Below - User has passed both if statments to successfully vote for the comment.
          @comment.upvote_by current_admin              #  Current admin votes.
          if @comment.save                              # Vote by admin is successfully committed to DB
            find_page_subject                           # Finds the page and then:
            @page.punches.create(hits: 1) unless @comment.commentable_type == "LibraryUpload"             # Adds a punch for an upvote on a comment to track trending.
            # Below - Adds an upvote activity when comment is upvoted (views/public_activity/comment/upvote).
            @comment.create_activity :upvote, owner: current_admin, recipient: @comment.admin 
            # BElow - Create a notification for an upvote
            Notification.create(recipient: @comment.admin, actor: current_admin, action: "endorsed", notifiable: @comment)
            respond_to do |format|
              format.html do 
                flash[:notice] = "You have successfully endorsed this comment by #{@comment.admin.name}"
                redirect_to request.referrer
              end # End - HTML Response
              format.js 
            end   # End - Respond block for html/js response
          else  # For some reason, user couldn't vote for.
            respond_to do |format|
              format.html do 
                flash[:notice] = "You have successfully endorsed this comment by #{@comment.admin.name}"
                redirect_to request.referrer
              end # End - HTML Response
            render js: "alert('For some reason you cannot endorse this comment. Please contact us.')"
            end # End - Respond block for html/js response 
          end   # End - If statement of user voting for comment.
        end   # End - If statement for determining if user has already voted for comment or not.
      else  # User who is voting for the comment is the user who created the comment.
        flash[:alert] = "You cannot endorse your own comment."
        redirect_to request.referrer
      end  # End - If statement to check for admin voting on their own comment  or not.
    #else # Upvate in public user
      # Begin - User check for upvoting, whether admin or logged in user.
      #authorize @comment # Ensures user is logged in.
      # Begin - If statement to check for user voting on their own comment or not.
#     if @comment.user != current_user            # User who is voting for the comment is not the user who created it.     
#       # Begin - If statement for determining if user has already voted for comment or not.
#       if current_user.voted_for? @comment       # Checks for :true if user has already voted for comment. Goes to Else if user has not yet voted for city review.
#         respond_to do |format|
#           format.html do 
#             # Below - User has not yet voted for comment and user has not commentableed the comment they're voting for.
#             flash[:warning] = "You have already endorsed this comment by #{@comment.user.name}"
#             redirect_to request.referrer
#           end # End - HTML Response
#           # Below - Renders an alert, notifying the user they alrady endorsed.
#           render js: "alert('You have already endorsed this comment by #{@comment.user.name}')"
#           #format.js 
#         end # End - Respond to block for html/js response.
#       else # User is voting on the Comment for the first time.
#       # Below - User has passed both if statments to successfully vote for the comment.
#         @comment.upvote_by current_user               #  Currenty user votes.
#         if @comment.save                              # Vote by user is successfully committed to DB
#           find_page_subject                           # Finds the page and then:
#           @page.punches.create(hits: 1)               # Adds a punch for an upvote on a comment to track trending.
#           # Below - Adds an upvote activity when comment is upvoted (views/public_activity/comment/upvote).
#           @comment.create_activity :upvote, owner: current_user, recipient: @comment.user 
#           # BElow - Create a notification for an upvote
#           Notification.create(recipient: @comment.user, actor: current_user, action: "endorsed", notifiable: @comment)
#           respond_to do |format|
#             format.html do 
#               flash[:notice] = "You have successfully endorsed this comment by #{@comment.user.name}"
#               redirect_to request.referrer
#             end # End - HTML Response
#             format.js 
#           end   # End - Respond block for html/js response
#         else  # For some reason, user couldn't vote for city review.
#           respond_to do |format|
#              format.html do 
#                flash[:notice] = "You have successfully endorsed this comment by #{@comment.user.name}"
#                redirect_to request.referrer
#              end # End - HTML Response
#            render js: "alert('For some reason you cannot endorse this comment. Please contact us.')"
#            end # End - Respond block for html/js response 
#          end   # End - If statement of user voting for comment.
#        end   # End - If statement for determining if user has already voted for comment or not.
#      else  # User who is voting for the comment is the user who created the comment.
#        flash[:alert] = "You cannot endorse your own comment."
#        redirect_to request.referrer
#      end  # End - If statement to check for user voting on their own city review or not.
   # end  # End - Workplace/admin check
  end   # End - Sets up upvote method.
  # End - Acts_as_votable Controller methods for city_reviews.

  private
    # Below - Permitted Params in the creation of a Complaint. Did not include three stages: (:completed, :filed, :pending).
    def comment_params
      params.require(:comment).permit(:description, :admin_id, :user_id, :commentable_type, :commentable_id, :parent_id, :subject) #:parent_id ,:title)
    end
    
    # Below - Is called during Update, when updating a comment is being invoked.
    def update_comment
      respond_to do |format|
        if @edit_comment.update(comment_params)
          format.html do 
            if @edit_comment.commentable_type == "Comment"
              flash[:notice] = "Your reply has been successfully edited!" 
            else # Comment is NOT a reply
              flash[:notice] = "Your comment has been successfully edited!" 
            end # End - Check if comment or reply
            redirect_to request.referrer # Renders traditional page refresh if HTML
          end # End - HTML do block
          format.js # Renders update.js.erb script
        else # Comment did not update
          find_comment_errors
          if @edit_comment.commentable_type == "Comment"
            # Below - Renders an alert, notifying the user they alrady endorsed.
            render js: "alert('This comment could not be updated. Reasons: #{@errors}.')"
          else # Not a reply
            render js: "alert('This reply could not be updated. Reasons: #{@errors}.')"
          end # End - Comment/reply if check.
          # End - Flash message changes depending on a reply or comment.     
          redirect_to request.referrer # Renders traditional page refresh if HTML
        end # End - If update succeeds or fails. 
      end # End - Respond to do block for html/js.
    end   
    
    # Below - Is called during Create, when comment creation is being invoked.
    def save_comment
      respond_to do |format| 
        if @comment.save  # SUCCESS: Comment posts
          # Below - Assigning trending punching to the parent subject (IE: "Post, Complaint, CityReview").
          find_page_subject
          @page.punches.create(hits: 1) unless @comment.commentable_type == "LibraryUpload"
          # Below - Creates notification and activity for a comment or a reply inside Notifications_helper.rb
          if @comment.commentable_type == "Comment" # Comment is on a comment, a reply
            if is_admin_resource?(@page) 
              unless Comment.find_by_id(@comment.commentable.id).admin == @comment.admin
                Notification.create(recipient: Comment.find_by_id(@comment.commentable.id).admin, actor: current_admin, action: "replied", notifiable: @comment)
                @comment.create_activity :create, owner: current_admin, recipient: @comment.admin
              end 
            else
              unless Comment.find_by_id(@comment.commentable.id).user == @comment.user
                Notification.create(recipient: Comment.find_by_id(@comment.commentable.id).user, actor: current_user, action: "replied", notifiable: @comment)
                @comment.create_activity :create, owner: current_user, recipient: @comment.user
              end 
            end 
          else  # COmment is a new comment on a page
            if is_admin_resource?(@page) # Comment is done in workplace, by admin
              unless @page.admin == @comment.admin 
                Notification.create(recipient: @page.admin, actor: current_admin, action: "commented", notifiable: @comment)
                @comment.create_activity :create, owner: current_admin, recipient: @page.admin
              end
            else   # COmment is done by user
              unless @page.user == @comment.user 
                Notification.create(recipient: @page.user, actor: current_user, action: "commented", notifiable: @comment)
                @comment.create_activity :create, owner: current_user, recipient: @page.user
              end
            end 
          end 
          format.js # Renders AJAX comments/create.js.erb
          # Begin - Flash message changes depending on a reply or comment.
          format.html do # Renders traditional page refresh if HTML
            if @comment.commentable_type == "Comment"
              flash[:notice] = "Your reply has successfully posted!" 
            else
              flash[:notice] = "Your comment has successfully posted!" 
            end
            redirect_to request.referrer
          end
          # End - Flash message changes depending on a reply or comment.
        else # FAILURE: Comment could not be posted
          find_comment_errors
          format.html do 
            # Begin - Flash message errors changes depending on a reply or comment.
            if @comment.commentable_type == "Comment"
              flash[:alert] = "Your reply could not be posted: #{@errors}" 
            else # Not a reply
              flash[:alert] = "Your comment could not be posted: #{@errors}." 
            end 
            # End - Flash message changes depending on a reply or comment.     
            redirect_to request.referrer # Renders traditional page refresh if HTML
          end
        end
      end # respond to do block
    end 
    
    # Below - Sets Commentable variable for polymorphic association with complaints or other comments. 
    def set_commentable
      @commentable = Comment.find_by_id(params[:comment_id]) if params[:comment_id]
      @commentable = Complaint.friendly.find(params[:complaint_id]) if params[:complaint_id]
      @commentable = CityReview.friendly.find(params[:review_id]) if params[:review_id]
      @commentable = Concern.friendly.find(params[:concern_id]) if params[:concern_id]
      @commentable = Post.friendly.find(params[:post_id]) if params[:post_id]
      @commentable = DepartmentReview.friendly.find(params[:department_review_id]) if params[:department_review_id]
      @commentable = Petition.friendly.find(params[:petition_id]) if params[:petition_id]
      @commentable = WorkplacePost.friendly.find(params[:workplace_post_id]) if params[:workplace_post_id]
      @commentable = WorkplaceMapPost.friendly.find(params[:workplace_map_post_id]) if params[:workplace_map_post_id]
      @commentable = LibraryUpload.friendly.find(params[:library_upload_id]) if params[:library_upload_id]
    end
    
    # Below - Called in a before action for user related modification to comments, like 'Edit, Destroy, Update'.
    def set_comment_and_user
      @user = User.friendly.find(params[:user_id]) if params[:user_id]
      @user = Admin.friendly.find(params[:admin_id]) if params[:admin_id]
      @comment = Comment.find(params[:id])
    end 
    
    # Below - Finds the parent of Comments, the subject of the page like Post, Complaint and CityReview, etc.
    def find_page_subject
      @page_parent = @comment.subject # Assigns the parent type so a punch can be added.
      @page_id = @comment.parent_id   # Finds the parent type's ID so a punch can be added.
      @page = @page_parent.constantize.find(@page_id) # Finds the page to add the punch to.
    end 
    
    # Below - Sets Workplace ID for admin comments 
    def set_workplace 
      @workplace = Workplace.friendly.find(params[:workplace_id])
    end 
    
    # Below - Finds errors related to @comment not saving in else statements. Needed due to reducing error code redundancy on Subject pages.
    def find_comment_errors 
      @comment.errors.each_with_index do |msg, i|
        @errors = msg[1]
      end 
    end 
end
