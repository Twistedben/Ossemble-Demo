class PostsController < OssemblyController
# Main controller for Posts. Inherits from Ossembly Controller
  # Below - Before_action that sets the city ID.
  before_action :set_city, except: [:edit, :update, :destroy]
  # Below - Before_action that sets the instance variables for topics/subtopics for filter panel, done in OssemblyController.
  before_action :set_topics, except: [:edit, :update, :destroy]
  # Below - Before_action that sets the post ID instance variable through params.
  before_action :set_post, only: [:show, :update, :upvote]
  # Below - BEfore_action that sets all city topics
  before_action :set_city_topics, except: [:edit, :update, :destroy]
  # Below - BEfore_action that sets all city topics
  before_action :set_city_subtopics, except: [:edit, :update, :destroy]
  
  
  def show
    @topic =  @post.topic.friendly_id
    @subtopic = @post.subtopic.friendly_id
    # Below - adds punch counter to Posts.
    @post.punch(request)
    @post_comments = @post.comments
    @voters = @post.votes_for.voters 
    # Below - Sets up meta tags for sharing posts' show pages.
    if @post.image.attached? # Post has an image attached
      set_meta_tags title: @post.title,
        site: 'Ossemble',
        description: @post.description, 
        keywords: @post.title,
        image_src: url_for(@post.image),
        twitter: {
          site: "@ossemble",
          title: @post.title,
          description: @post.description,
          image: url_for(@post.image)
        },
        og: {
          type: "website",
          title: @post.title,
          url: subtopic_post_url(@city, @post, @post.topic, @post.subtopic),
          description: @post.description,
          image: url_for(@post.image)
        }
    else # Post doesn't have an image
      set_meta_tags title: @post.title,
        site: 'Ossemble',
        description: @post.description, 
        keywords: @post.title,
        twitter: {
          site: "@ossemble",
          title: @post.title,
          description: @post.description
        },
        og: {
          type: "website",
          title: @post.title,
          url: subtopic_post_url(@city, @post, @post.topic, @post.subtopic),
          description: @post.description
        }
    end 
  end

  def new
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to new page.
      flash[:alert] = "You must join Ossemble to start a #{@city.name} Conversation."
      cookies[:stored_location] = new_subtopic_post_path(@city)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      @post = Post.new
    end
  end

  def edit
    @user = User.find(params[:user_id])
    @edit_post = Post.friendly.find(params[:id])
    authorize @edit_post
    @post_topic = @edit_post.topic.friendly_id
    @post_subtopic = @edit_post.subtopic.friendly_id
    @city = @edit_post.city
    @topics = @city.topics 
    @subtopics = @city.subtopics 
  end

  def create
    @post = Post.new(post_params)
    @city = City.friendly.find(params[:city_id])
    # Below - Assigns user id to post creation.
    @post.user_id = current_user.id
    @post_topic = @post.topic.friendly_id
    @post_subtopic = @post.subtopic.friendly_id
    @post.city_id = @city.id
    #authorize @post
    # Begin - If statement for post creation.
    if @post.save # If it saves, display Flash message success, if not move to 'else'
      # Below - Adds to a users activity stream when creating a post and assigns recipient to the city
      @post.create_activity :create, owner: current_user, recipient: @post.city
      flash[:notice] = "Your #{@post.subtopic.name} post for #{@city.name} has been successfully submitted!"   # Shows a Flash message of success
      redirect_to subtopic_post_path(@city, @post_topic, @post_subtopic, @post)  # Redirects to the Post's show page.
    else
      flash[:alert] = "Could not submit your #{@post.subtopic.name} post for #{@city.name}. See why below!"   # Shows a Flash message of error
      render 'new' # Reload the New template with errors
    end # End - If statement for post creation.
  end

  def update
    # Below - Assigns user id to post creation.
    @edit_post = Post.friendly.find(params[:id])
    @edit_post.user_id = current_user.id
    @post_topic = @edit_post.topic.friendly_id
    @post_subtopic = @edit_post.subtopic.friendly_id
    authorize @edit_post # Ensures the user is owner of edited post.
    if @edit_post.update(post_params)
      flash[:notice] = "Your post, titled #{@edit_post.title}, has been updated successfully!"
      redirect_to subtopic_post_path(@edit_post.city.friendly_id, @post_topic, @post_subtopic, @edit_post.friendly_id)
    else 
      flash[:alert] = "Your post, titled #{@edit_post.title}, could not be updated. See why below!"
      render 'edit'
    end 
  end

  def destroy
   # Calls all user related params and ids from a before action above.
    @user = User.find(params[:user_id])
    @edit_post = Post.friendly.find(params[:id])
    authorize @edit_post
    if @user === current_user
      if @edit_post.destroy
        flash[:notice] = "Your Post has been deleted."
        redirect_to city_ossembly_path(@user.city.friendly_id)
      else 
        flash[:alert] = "Your Post could not be deleted for some unknown reason. Please contact us."
        render 'edit'
      end
    end
  end
   
  # Begin - Acts_as_votable Controller method for Posts.
  def upvote 
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to show page.
      flash[:alert] = "You must create an account and join #{@post.city.name} to Endorse this #{@post.subtopic.name} Post."
      cookies[:stored_location] = subtopic_post_path(@city, @post.topic, @post.subtopic, @post)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      # Begin - If statement to check for user voting on their own city review or not.
      if @post.user != current_user            # User who is voting for the city review is not the user who created it.     
        # Begin - If statement for determining if user has already voted for city review or not.
        if current_user.voted_for? @post       # Checks for :true if user has already voted for city review. Goes to Else if user has not yet voted for city review.
          # Below - User has not yet voted for city review and user has not posted the city review they're voting for.
          flash[:warning] = "You have already endorsed this post by #{@post.user.name}"
          redirect_to subtopic_post_path(@city, @post.topic.friendly_id, @post.subtopic.friendly_id, @post)
        else # User is voting on the City Review for the first time.
          authorize @post
          # Below - User has passed both if statments to successfully vote for the City Review.
          @post.upvote_by current_user               #  Currenty user votes.
          if @post.save                              # Vote by user is successfully committed to DB
            Notification.create(recipient: @post.user, actor: current_user, action: "endorsed", notifiable: @post)
            # Below - Adds to a users activity stream when endorsing a post and assigns recipient to the owner of the post.
            @post.create_activity :upvote, owner: current_user, recipient: @post.user
            @post.punches.create(hits: 2)            # Adds 2 to trending counter when city review is voted on.
            flash[:notice] = "You have successfully endorsed this #{@post.subtopic.name} post by #{@post.user.name}"
            redirect_to subtopic_post_path(@city, @post.topic.friendly_id, @post.subtopic.friendly_id, @post)
          else  # For some reason, user couldn't vote for city review.
            flash[:alert] = "Could not endorse this  #{@post.subtopic.name} post."
            redirect_to subtopic_post_path(@city, @post.topic.friendly_id, @post.subtopic.friendly_id, @post)
          end   # End - If statement of user voting for city review.
        end   # End - If statement for determining if user has already voted for city review or not.
      else  # User who is voting for the city review is the user who created the city review.
        flash[:alert] = "You cannot endorse your own post."
        redirect_to subtopic_post_path(@city, @post.topic.friendly_id, @post.subtopic.friendly_id, @post)
      end  # End - If statement to check for user voting on their own city review or not.
    end # End of guest check
  end   # End - Sets up upvote method.
  # End - Acts_as_votable Controller methods for city_reviews.

  private
     # Below - Sets up the city for City Review
    def set_city
      @city = City.friendly.find(params[:city_id])
    end
    # Below - Sets up the post from URl.
    def set_post
      @post = Post.friendly.find(params[:id])
    end
    # Below - Sets up all city topics
    def set_city_topics
      @topics = @city.topics
    end
    # Below - Sets up all city cubtopics
    def set_city_subtopics 
      @subtopics = @city.subtopics
    end 
    
    # Below - Post params for creation of a new post.
    def post_params
      params.require(:post).permit(:title, :description, :slug, :subtopic_id, :user_id, :image)
    end
end
class PostsController < OssemblyController
# Main controller for Posts. Inherits from Ossembly Controller
  # Below - Before_action that sets the city ID.
  before_action :set_city, except: [:edit, :update, :destroy]
  # Below - Before_action that sets the instance variables for topics/subtopics for filter panel, done in OssemblyController.
  before_action :set_topics, except: [:edit, :update, :destroy]
  # Below - Before_action that sets the post ID instance variable through params.
  before_action :set_post, only: [:show, :update, :upvote]
  # Below - BEfore_action that sets all city topics
  before_action :set_city_topics, except: [:edit, :update, :destroy]
  # Below - BEfore_action that sets all city topics
  before_action :set_city_subtopics, except: [:edit, :update, :destroy]
  
  
  def show
    @topic =  @post.topic.friendly_id
    @subtopic = @post.subtopic.friendly_id
    # Below - adds punch counter to Posts.
    @post.punch(request)
    @post_comments = @post.comments
    @voters = @post.votes_for.voters 
    # Below - Sets up meta tags for sharing posts' show pages.
    if @post.image.attached? # Post has an image attached
      set_meta_tags title: @post.title,
        site: 'Ossemble',
        description: @post.description, 
        keywords: @post.title,
        image_src: url_for(@post.image),
        twitter: {
          site: "@ossemble",
          title: @post.title,
          description: @post.description,
          image: url_for(@post.image)
        },
        og: {
          type: "website",
          title: @post.title,
          url: subtopic_post_url(@city, @post, @post.topic, @post.subtopic),
          description: @post.description,
          image: url_for(@post.image)
        }
    else # Post doesn't have an image
      set_meta_tags title: @post.title,
        site: 'Ossemble',
        description: @post.description, 
        keywords: @post.title,
        twitter: {
          site: "@ossemble",
          title: @post.title,
          description: @post.description
        },
        og: {
          type: "website",
          title: @post.title,
          url: subtopic_post_url(@city, @post, @post.topic, @post.subtopic),
          description: @post.description
        }
    end 
  end

  def new
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to new page.
      flash[:alert] = "You must join Ossemble to start a #{@city.name} Conversation."
      cookies[:stored_location] = new_subtopic_post_path(@city)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      @post = Post.new
    end
  end

  def edit
    @user = User.find(params[:user_id])
    @edit_post = Post.friendly.find(params[:id])
    authorize @edit_post
    @post_topic = @edit_post.topic.friendly_id
    @post_subtopic = @edit_post.subtopic.friendly_id
    @city = @edit_post.city
    @topics = @city.topics 
    @subtopics = @city.subtopics 
  end

  def create
    @post = Post.new(post_params)
    @city = City.friendly.find(params[:city_id])
    # Below - Assigns user id to post creation.
    @post.user_id = current_user.id
    @post_topic = @post.topic.friendly_id
    @post_subtopic = @post.subtopic.friendly_id
    @post.city_id = @city.id
    #authorize @post
    # Begin - If statement for post creation.
    if @post.save # If it saves, display Flash message success, if not move to 'else'
     Notification.create(recipient: @post.user, actor: current_user, action: "endorsed", notifiable: @post)

      # Below - Adds to a users activity stream when creating a post and assigns recipient to the city
      @post.create_activity :create, owner: current_user, recipient: @post.city
      flash[:notice] = "Your #{@post.subtopic.name} post for #{@city.name} has been successfully submitted!"   # Shows a Flash message of success
      redirect_to subtopic_post_path(@city, @post_topic, @post_subtopic, @post)  # Redirects to the Post's show page.
    else
      flash[:alert] = "Could not submit your #{@post.subtopic.name} post for #{@city.name}. See why below!"   # Shows a Flash message of error
      render 'new' # Reload the New template with errors
    end # End - If statement for post creation.
  end

  def update
    # Below - Assigns user id to post creation.
    @edit_post = Post.friendly.find(params[:id])
    @edit_post.user_id = current_user.id
    @post_topic = @edit_post.topic.friendly_id
    @post_subtopic = @edit_post.subtopic.friendly_id
    authorize @edit_post # Ensures the user is owner of edited post.
    if @edit_post.update(post_params)
      flash[:notice] = "Your post, titled #{@edit_post.title}, has been updated successfully!"
      redirect_to subtopic_post_path(@edit_post.city.friendly_id, @post_topic, @post_subtopic, @edit_post.friendly_id)
    else 
      flash[:alert] = "Your post, titled #{@edit_post.title}, could not be updated. See why below!"
      render 'edit'
    end 
  end

  def destroy
   # Calls all user related params and ids from a before action above.
    @user = User.find(params[:user_id])
    @edit_post = Post.friendly.find(params[:id])
    authorize @edit_post
    if @user === current_user
      if @edit_post.destroy
        flash[:notice] = "Your Post has been deleted."
        redirect_to city_ossembly_path(@user.city.friendly_id)
      else 
        flash[:alert] = "Your Post could not be deleted for some unknown reason. Please contact us."
        render 'edit'
      end
    end
  end
   
  # Begin - Acts_as_votable Controller method for Posts.
  def upvote 
    if is_guest? # If the user is a guest, kicks them to signup, stores the cookie, after signup back to show page.
      flash[:alert] = "You must create an account and join #{@post.city.name} to Endorse this #{@post.subtopic.name} Post."
      cookies[:stored_location] = subtopic_post_path(@city, @post.topic, @post.subtopic, @post)
      redirect_to new_user_registration_path
    else # Is not a guest, so doesn't store location.  
      # Begin - If statement to check for user voting on their own city review or not.
      if @post.user != current_user            # User who is voting for the city review is not the user who created it.     
        # Begin - If statement for determining if user has already voted for city review or not.
        if current_user.voted_for? @post       # Checks for :true if user has already voted for city review. Goes to Else if user has not yet voted for city review.
          # Below - User has not yet voted for city review and user has not posted the city review they're voting for.
          flash[:warning] = "You have already endorsed this post by #{@post.user.name}"
          redirect_to subtopic_post_path(@city, @post.topic.friendly_id, @post.subtopic.friendly_id, @post)
        else # User is voting on the City Review for the first time.
          authorize @post
          # Below - User has passed both if statments to successfully vote for the City Review.
          @post.upvote_by current_user               #  Currenty user votes.
          if @post.save                              # Vote by user is successfully committed to DB
            # Below - Adds to a users activity stream when endorsing a post and assigns recipient to the owner of the post.
            @post.create_activity :upvote, owner: current_user, recipient: @post.user
            @post.punches.create(hits: 2)            # Adds 2 to trending counter when city review is voted on.
            flash[:notice] = "You have successfully endorsed this #{@post.subtopic.name} post by #{@post.user.name}"
            redirect_to subtopic_post_path(@city, @post.topic.friendly_id, @post.subtopic.friendly_id, @post)
          else  # For some reason, user couldn't vote for city review.
            flash[:alert] = "Could not endorse this  #{@post.subtopic.name} post."
            redirect_to subtopic_post_path(@city, @post.topic.friendly_id, @post.subtopic.friendly_id, @post)
          end   # End - If statement of user voting for city review.
        end   # End - If statement for determining if user has already voted for city review or not.
      else  # User who is voting for the city review is the user who created the city review.
        flash[:alert] = "You cannot endorse your own post."
        redirect_to subtopic_post_path(@city, @post.topic.friendly_id, @post.subtopic.friendly_id, @post)
      end  # End - If statement to check for user voting on their own city review or not.
    end # End of guest check
  end   # End - Sets up upvote method.
  # End - Acts_as_votable Controller methods for city_reviews.

  private
     # Below - Sets up the city for City Review
    def set_city
      @city = City.friendly.find(params[:city_id])
    end
    # Below - Sets up the post from URl.
    def set_post
      @post = Post.friendly.find(params[:id])
    end
    # Below - Sets up all city topics
    def set_city_topics
      @topics = @city.topics
    end
    # Below - Sets up all city cubtopics
    def set_city_subtopics 
      @subtopics = @city.subtopics
    end 
    
    # Below - Post params for creation of a new post.
    def post_params
      params.require(:post).permit(:title, :description, :slug, :subtopic_id, :user_id, :image)
    end
end
