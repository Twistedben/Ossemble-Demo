class WorkplacePostsController < WorkplacesController
# Main controller for Workplace Posts and inherits from the Workplaces controller
  # Below - Makes sure admin is logged in
  before_action :authenticate_admin!
  # Below - Before action that sets suggestion, admin, and workplace params
  before_action :set_admin,     only:   [:edit, :update, :destroy]
  before_action :set_workplace
  before_action :set_post,      except: [:index, :new, :create]   
  # Below - Before action that makes sure user is allowed to access workplace based on if they belong to it (Comes from Workplaces Controller)
  append_before_action :authenticate_workplace_membership
  
  def index
    @workplace_posts = @workplace.posts
  end

  def show
    @entry = LibraryEntry.new
    @workplace_post.punch(request)
    @workplace_post = WorkplacePost.friendly.find(params[:id])
    @workplace_post_comments = @workplace_post.comments
    @admins = @institute.admins
  end

  def new
    @workplace_post = @workplace.posts.new
    @admins = @workplace.admins
    @workplace_admins_path = new_institute_workplace_workplace_post_path(@institute, @workplace)
  end

  def create
    @workplace_post = @workplace.posts.build(post_params)
    @workplace_post.admin_id = current_admin.id
    #authorize @workplace_post # Ensures admin is part of workplace and is allowed to post.
    if @workplace_post.save 
      # Below - Adds to a users activity stream when creating a new city review (WUL) and assigns the city as the recipient of it.
      #@workplace_post.create_activity :create, owner: current_admin, recipient: @workplace_post.workplace
      # Below - upvotes upon creation of their own resource
      @workplace_post.upvote_by current_admin
      flash[:notice] = "Your Workplace Post in #{@workplace.name} has been posted!"   # Shows a Flash message of success
      redirect_to workplace_post_path(@institute, @workplace, @workplace_post)  # Redirects to the City Review's show page.
    else
      flash[:alert] = "Could not post your Workplace Post in #{@workplace.name}. See why below!"   # Shows a Flash message of error
      render 'new' # Reload the New template with errors
    end 
  end

  def edit
    #authorize @workplace_post # Ensures user is owner of post
    @admins = @workplace_post.workplace.admins
    @workplace_admins_path = new_institute_workplace_workplace_map_post_path(@institute, @workplace_post.workplace)
  end
  
  def update
    # Calls all user related params and ids from a before action above.
    #authorize @workplace_post # Ensures user is owner of city review.
    if @workplace_post.update(post_params)
      flash[:notice] = "Your Workplace Post in #{@workplace_post.workplace.name} has been updated successfully!"
      redirect_to workplace_post_path(@institute, @workplace_post.workplace, @workplace_post)
    else 
      flash[:alert] = "Your Workplace Post in #{@workplace_post.workplace.name} could not be updated. See why below!"
      render 'edit'
    end 
  end 

  def destroy
    # Calls all user related params and ids from a before action above.
    #authorize @workplace_post # Ensures user is destrroying thier own review.
    if @workplace_post.admin === current_admin
      if @workplace_post.destroy
        flash[:notice] = "Your Workplace Post in #{@workplace_post.workplace.name} has been deleted."
        redirect_to workplace_posts_path(@institute, @workplace_post.workplace)
      else 
        flash[:alert] = "Your Workplace Post in #{@workplace_post.workplace.name} could not be deleted for some unknown reason. Please contact us."
        render 'edit'
      end
    end
  end
  
  def save_post_to_library
    @entry = @workplace_post.library_entries.build(admin_library_id: current_admin.library.id)
    if @entry.save 
      flash[:notice] = "You've saved #{@workplace_post.title} to your Archive!"
      render 'show'
    else 
      flash[:alert] = "Could not save this to your Archive. See why below!"
      render 'show'
    end 
  end 
  
  def upvote 
    # Begin - If statement to check for admin voting on their own city review or not.
    if @workplace_post.admin != current_admin            # admin who is voting for the city review is not the admin who created it.     
      # Begin - If statement for determining if admin has already voted for city review or not.
      if current_admin.voted_for? @workplace_post       # Checks for :true if admin has already voted for city review. Goes to Else if admin has not yet voted for city review.
        # Below - admin has not yet voted for city review and admin has not posted the city review they're voting for.
        flash[:warning] = "You have already endorsed this post by #{@workplace_post.admin.name}"
        redirect_to request.referrer 
      else # admin is voting on the City Review for the first time.
        #authorize @workplace_post
        # Below - admin has passed both if statments to successfully vote for the City Review.
        @workplace_post.upvote_by current_admin               #  Currenty admin votes.
        if @workplace_post.save                              # Vote by admin is successfully committed to DB
          Notification.create(recipient: @workplace_post.admin, actor: current_admin, action: "endorsed", notifiable: @workplace_post)
          # Below - Adds to a admins activity stream when endorsing a post and assigns recipient to the owner of the post.
          @workplace_post.create_activity :upvote, owner: current_admin, recipient: @workplace_post.admin
          @workplace_post.punches.create(hits: 2)            # Adds 2 to trending counter when city review is voted on.
          flash[:notice] = "You have successfully upvoted this #{@workplace_post.workplace.name} forum post by #{@workplace_post.admin.name}"
          redirect_to request.referrer
        else  # For some reason, admin couldn't vote for city review.
          flash[:alert] = "Could not endorse this  #{@workplace_post.workplace.name} forum post."
          redirect_to request.referrer
        end   # End - If statement of admin voting for city review.
      end   # End - If statement for determining if admin has already voted for city review or not.
    else  # admin who is voting for the city review is the admin who created the city review.
      flash[:alert] = "You cannot endorse your own post."
      redirect_to request.referrer
    end  # End - If statement to check for admin voting on their own city review or not.
  end   # End - Sets up upvote method.

  private 
  
  # Below -  
  def set_admin
     @admin = Admin.friendly.find(params[:admin_id])
  end   
  
  # Overrides the set workplace in Workplaces_controller by supplying workplace_id over id
  def set_workplace 
    @workplace = Workplace.friendly.find(params[:workplace_id])
  end 
  
  # Below -  Finds and sets the Workplace Post
  def set_post 
    @workplace_post = WorkplacePost.friendly.find(params[:id]) 
  end   
  
  # Params for creation of a post
  def post_params
    params.require(:workplace_post).permit(:title, :description, :slug, :image, :file, :post_category_id, :tags)
  end 

  
end
