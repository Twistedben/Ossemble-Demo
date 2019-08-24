class WorkplaceMapPostsController < WorkplacesController
# Main Map Posts controller for creating reports (complaints) on a map inside Workplaces and through admins.
  # Inherits from Workplaces Controller.
  # Below - Makes sure admin is logged in
  before_action :authenticate_admin!
  # Below - Before action that sets suggestion, admin, and workplace params
  before_action :set_admin,   only:   [:edit, :update, :destroy]
  before_action :set_workplace
  before_action :set_post,    except: [:index, :new, :create, :suggestions, :reports, :others] 
  # Below - Before action that makes sure user is allowed to access workplace based on if they belong to it (Comes from Workplaces Controller)
  append_before_action :authenticate_workplace_membership

  def index
    @map_posts = @workplace.map_posts
  end

  def show
    @entry = LibraryEntry.new
    @map_post.punch(request)
    @map_post_comments = @map_post.comments
  end
  
  def new  
    @map_post = @workplace.map_posts.new
    @admins = @workplace.admins
    @workplace_admins_path = new_institute_workplace_workplace_map_post_path(@institute, @workplace)
    @shapes = @map_post.shapes.build
  end 

  def create
    @map_post = @workplace.map_posts.build(map_post_params)
    @map_post.admin_id = current_admin.id
    #authorize @map_post # Ensures admin is part of workplace and is allowed to report.
    if @map_post.save 
      # Below - Adds to a admins activity stream when creating a new map post (WUL) and assigns the city as the recipient of it.
      #@map_post.create_activity :create, owner: current_admin, recipient: @map_post.workplace
      # Below - Provides initial upvote by the creator
      @map_post.upvote_by current_admin
      flash[:notice] = "Your Map Post in #{@workplace.name} has been posted!"   # Shows a Flash message of success
      redirect_to workplace_map_post_path(@institute, @workplace, @map_post)  # Redirects to the map post's show page.
    else
      flash[:alert] = "Could not submit your Map Post in #{@workplace.name}. See why below!"   # Shows a Flash message of error
      render 'new' # Reload the New template with errors
    end 
  end

  def edit
    @edit_map_post = WorkplaceMapPost.friendly.find(params[:id]) 
    @admins = @edit_map_post.workplace.admins
    @workplace_admins_path = new_institute_workplace_workplace_map_post_path(@institute, @edit_map_post.workplace)
    @shapes = @map_post.shapes.first
  end

  def update
    @map_post.shapes.first.destroy if @map_post.shapes.first != nil
    # Calls all admin related params and ids from a before action above.
    #authorize @workplace_post # Ensures admin is owner of map post.
    if @map_post.update(map_post_params)
      flash[:notice] = "Your Map Post in #{@map_post.workplace.name} has been updated successfully!"
      redirect_to workplace_map_post_path(@institute, @map_post.workplace, @map_post)
    else 
      flash[:alert] = "Your Workplace Map Post in #{@map_post.workplace.name} could not be updated. See why below!"
      render 'edit'
    end 

  end
  
  def destroy
    # Calls all admin related params and ids from a before action above.
    #authorize @workplace_post # Ensures admin is destrroying thier own review.
    if @map_post.admin === current_admin
      if @map_post.destroy
        flash[:notice] = "Your Map Post in #{@map_post.workplace.name} has been deleted."
        redirect_to workplace_map_posts_path(@institute, @map_post.workplace)
      else 
        flash[:alert] = "Your Map Post in #{@map_post.workplace.name} could not be deleted for some unknown reason. Please contact us."
        render 'edit'
      end
    end
  end
  
  # Below - POST: Upvotes for Workplace Map Posts
  def upvote 
    # Begin - If statement to check for admin voting on their own map post or not.
    if @map_post.admin != current_admin            # admin who is voting for the map post is not the admin who created it.     
      # Begin - If statement for determining if admin has already voted for map post or not.
      if current_admin.voted_for? @map_post       # Checks for :true if admin has already voted for map post. Goes to Else if admin has not yet voted for map post.
        # Below - admin has not yet voted for map post and admin has not posted the map post they're voting for.
        flash[:warning] = "You have already endorsed this post by #{@map_post.admin.name}"
        redirect_to request.referrer
      else # admin is voting on the map post for the first time.
        #authorize @map_post
        # Below - admin has passed both if statments to successfully vote for the map post.
        @map_post.upvote_by current_admin               #  Currenty admin votes.
        if @map_post.save                              # Vote by admin is successfully committed to DB
          Notification.create(recipient: @map_post.admin, actor: current_admin, action: "endorsed", notifiable: @map_post)
          # Below - Adds to a admins activity stream when endorsing a post and assigns recipient to the owner of the post.
          @map_post.create_activity :upvote, owner: current_admin, recipient: @map_post.admin
          @map_post.punches.create(hits: 2)            # Adds 2 to trending counter when map post is voted on.
          flash[:notice] = "You have successfully upvoted this #{@map_post.workplace.name} map post by #{@map_post.admin.name}"
          redirect_to request.referrer
        else  # For some reason, admin couldn't vote for map post.
          flash[:alert] = "Could not endorse this #{@map_post.workplace.name} post."
          redirect_to request.referrer
        end   # End - If statement of admin voting for map post.
      end   # End - If statement for determining if admin has already voted for map post or not.
    else  # admin who is voting for the map post is the admin who created the map post.
      flash[:alert] = "You cannot endorse your own post."
      redirect_to request.referrer
    end  # End - If statement to check for admin voting on their own map post or not.
  end   # End - Sets up upvote method.

  # Below - POST: Saves Workplace Map Post to library
  def save_map_post_to_library
    @entry = @map_post.library_entries.build(admin_library_id: current_admin.library.id)
    if @entry.save 
      flash[:notice] = "You've saved #{@map_post.title} to your Archive!"
      render 'show'
    else 
      flash[:alert] = "Could not save this to your Archive. See why below!"
      render 'show'
    end 
  end 
  
  # Below -  Scoped suggestions for map posts
  def suggestions 
    @map_posts = @workplace.map_posts.suggestions
    render action: :index
  end   
  
  # Below - Scoped reports for map posts 
  def reports 
    @map_posts = @workplace.map_posts.reports
    render action: :index
  end   
  
  # Below -  Scoped others for map posts
  def others 
    @map_posts = @workplace.map_posts.others
    render action: :index
  end   
  
  private 
  
  # Below - Sets admin for editing page
  def set_admin 
    @admin = Admin.friendly.find(params[:admin_id])
  end   
  
  # Overrides the set workplace in Workplaces_controller by supplying workplace_id over id
  def set_workplace 
    @workplace = Workplace.friendly.find(params[:workplace_id])
  end 
  
  # Below -  Finds and sets the Map Post
  def set_post
    @map_post = WorkplaceMapPost.friendly.find(params[:id]) 
  end   

  # Below -  Provides the field attributes for workplace map posts.
  def map_post_params 
    params.require(:workplace_map_post).permit(:title, :address, :description, :tags, :map_post_category_id, :file, :image, shapes_attributes: [:id, :geo, :description, :workplace_map_post_id, :_destroy])
  end   
end
