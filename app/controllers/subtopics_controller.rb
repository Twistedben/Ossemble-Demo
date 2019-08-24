class SubtopicsController < TopicsController
# Main controller for Subtopics, inherits from Topics Controller.
   # Below - Before_action that sets the city ID.
  before_action :set_city
  # Below - Before_action that sets the instance variables for topics/subtopics for filter panel, done in OssemblyController.
  before_action :set_topics
  # Below - Before_action that sets the topic id.
  before_action :set_topic
  # Below - Before_action that sets the subtopic ID.
  before_action :set_subtopic


  def show
   # @subtopic.punch(request)
    if params[:sort_by] == "date"
      @week_subtopic_posts = @subtopic.posts.order('created_at DESC').limit(6)
      @month_subtopic_posts = @subtopic.posts.order('created_at DESC').offset(6)
    elsif params[:sort_by] == "endorsements"
      @week_subtopic_posts = @subtopic.posts.limit(6).sort_by { |p| p.votes_for.size }
      @week_subtopic_posts.reverse!      
      @month_subtopic_posts = @subtopic.posts.offset(6).sort_by { |p| p.votes_for.size }
      @month_subtopic_posts.reverse!
    elsif params[:sort_by] == "comments"
      @week_subtopic_posts = @subtopic.posts.limit(6).sort_by { |p| p.count_comments }
      @week_subtopic_posts.reverse!   
      @month_subtopic_posts = @subtopic.posts.offset(6).sort_by { |p| p.count_comments }
      @month_subtopic_posts.reverse!
    elsif params[:sort_by] == "trending"
      @week_subtopic_posts = @subtopic.posts.limit(6).sort_by { |p| p.hits }
      @week_subtopic_posts.reverse!      
      @month_subtopic_posts = @subtopic.posts.offset(6).sort_by { |p| p.hits }
      @month_subtopic_posts.reverse!
    else 
      # Below - Renders in all posts trending within a week inside of given topic.
      @week_subtopic_posts = @subtopic.posts.most_hit(1.week.ago, 6)
      # Below - Renders in all posts trending within a month inside of given topic.
      @month_subtopic_posts = @subtopic.posts.most_hit(1.month.ago, nil).offset(6)
    end 
  end

=begin - The CRUD actions for subtopics that aren't yet in use.
  def new
    @subtopic = Subtopic.new
  end

  def edit
  end

  def create
    @subtopic = @topic.subtopics.build(subtopic_params)
    
    respond_to do |format|
      if @subtopic.save
        format.html { redirect_to @subtopic, notice: 'Subtopic was successfully created.' }
        format.json { render :show, status: :created, location: @subtopic }
      else
        format.html { render :new }
        format.json { render json: @subtopic.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @subtopic.update(subtopic_params)
        format.html { redirect_to @subtopic, notice: 'Subtopic was successfully updated.' }
        format.json { render :show, status: :ok, location: @subtopic }
      else
        format.html { render :edit }
        format.json { render json: @subtopic.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @subtopic.destroy
    respond_to do |format|
      format.html { redirect_to subtopics_url, notice: 'Subtopic was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
=end - CRUD actions for subtopics that aren't yet in use
  private
    
    # Below - Sets up the url id for subtopic.
    def set_subtopic
      @subtopic = Subtopic.friendly.find(params[:id])
    end
    # Below - Sets up topic ID from URL.
    def set_topic
      @topic = Topic.friendly.find(params[:topic_id])
    end
    # Below - Sets up subtopic params for creation of a new subtopic.
    #def subtopic_params
    #  params.require(:subtopic).permit(:name, :description, :slug, :topic_id, :user_id)
    #end
end
