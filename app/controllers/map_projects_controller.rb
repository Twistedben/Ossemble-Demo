class MapProjectsController < WorkplacesController
  before_action :set_map_project, only: [:show, :edit, :update, :destroy]
  before_action :set_admin,   only:   [:edit, :update, :destroy]
  before_action :set_workplace

  # GET /map_projects
  # GET /map_projects.json
  def index
    @map_projects = MapProject.all
  end

  # GET /map_projects/1
  # GET /map_projects/1.json
  def show
    @entry = LibraryEntry.new
    @map_projects_comments = @map_projects.comments
  end

  # GET /map_projects/new
  def new
    @map_project = @workplace.projects.new
    @admins = @workplace.admins
    @workplace_admins_path = new_map_project_path(@institute, @workplace)
    @shapes = @map_project.shapes.build
  end

  # GET /map_projects/1/edit
  def edit
  end

  # POST /map_projects
  # POST /map_projects.json
  def create
    @map_project = @workplace.projects.build(map_project_params)
    @map_project.admin_id = current_admin.id
    #authorize @map_post # Ensures admin is part of workplace and is allowed to report.
    if @map_project.save 
      # Below - Adds to a admins activity stream when creating a new map post (WUL) and assigns the city as the recipient of it.
      flash[:notice] = "Your Project in #{@workplace.name} has been posted!"   # Shows a Flash message of success
      redirect_to map_project_path(@institute, @workplace, @map_project)  # Redirects to the map post's show page.
    else
      flash[:alert] = "Could not submit your Project in #{@workplace.name}. See why below!"   # Shows a Flash message of error
      render 'new' # Reload the New template with errors
    end 
  end

  # PATCH/PUT /map_projects/1
  # PATCH/PUT /map_projects/1.json
  def update
    respond_to do |format|
      if @map_project.update(map_project_params)
        format.html { redirect_to @map_project, notice: 'Map project was successfully updated.' }
        format.json { render :show, status: :ok, location: @map_project }
      else
        format.html { render :edit }
        format.json { render json: @map_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /map_projects/1
  # DELETE /map_projects/1.json
  def destroy
    @map_project.destroy
    respond_to do |format|
      format.html { redirect_to map_projects_url, notice: 'Map project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
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
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_map_project
      @map_project = MapProject.find(params[:id])
    end

    # Below - Sets admin for editing page
    def set_admin 
      @admin = Admin.friendly.find(params[:admin_id])
    end   

    # Overrides the set workplace in Workplaces_controller by supplying workplace_id over id
    def set_workplace 
      @workplace = Workplace.friendly.find(params[:workplace_id])
    end 

  # Never trust parameters from the scary internet, only allow the white list through.
  def map_project_params
    params.require(:map_project).permit(:title, :status, :description, :address, :slug, :tags, :admin_id, :workplace_id, files: [], images: [], shapes_attributes: [:id, :geo, :description, :workplace_map_post_id, :_destroy])
  end
end
