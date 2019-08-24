class InstitutesController < ApplicationController
  # Below - Before action that ensures admin is logged in
  before_action :authenticate_admin!
  
  # Below - Before action that sets admin
  before_action :set_admin
  
  before_action :set_institute, only: [:show, :edit, :update, :destroy]

  # GET /institutes
  # GET /institutes.json
  def index
    @institutes = Institute.all
  end

  # GET /institutes/1
  # GET /institutes/1.json
  def show
  end

  # GET /institutes/new
  def new
    @institute = Institute.new
  end

  # GET /institutes/1/edit
  def edit
  end

  # POST /institutes
  # POST /institutes.json
  def create
    @institute = Institute.new(institute_params)
    # Below - sets @area variable based on the institute's category selection so redirection can be done on Workplace Shape New page for map
    case @institute.category
    when "campaign"
      @area = "district"
    when "county" 
      @area = "county"
    when "city"
      @area = "city"
    when "other" || "regional"
      @area = "custom"
    else
      @area = nil
    end 
    if @institute.save
      @main_workplace = @institute.workplaces.build(name: "#{@institute.name} Channel", description: "Main Channel for #{@institute.name}. This first Channel is automatically provided for employees to collaborate within it. This channel can be private for co-workers with matching work email domains to join or public so anyone invited can join.", is_main: true)
      @admin.update(institute_id: @institute.id) # Makes the admin join institute.
      @main_workplace.join_workplace(current_admin)
      # Below - Creates a free subscription for a newly signed up institute. MEthod is called in Institute.rb model's creation callback.
      Subscription.create(admin_id: current_admin.id, plan_id: 1, active: true, institute_id: @institute.id, status: "active") unless @institute.has_subscription?
      if @main_workplace.save 
        flash[:notice] = "Your Workplace, #{@institute.name}, has successfully been created! Now, let's assign a location on the map for your first Channel."
        redirect_to new_workplace_shape_path(@institute, @main_workplace, map: @area)
      end
    else 
      flash[:alert] = "Your Workplace could not be created. See why below!"
      render 'new'
    end 
   
  end

  # PATCH/PUT /institutes/1
  # PATCH/PUT /institutes/1.json
  def update
    respond_to do |format|
      if @institute.update(institute_params)
        format.html { redirect_to @institute, notice: 'Institute was successfully updated.' }
        format.json { render :show, status: :ok, location: @institute }
      else
        format.html { render :edit }
        format.json { render json: @institute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /institutes/1
  # DELETE /institutes/1.json
  def destroy
    @institute.destroy
    respond_to do |format|
      format.html { redirect_to institutes_url, notice: 'Institute was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  # Below -  
  def admins_json 
    @institute = Institute.find(params[:institute_id])
    @admins = @institute.admins
    respond_to do |format|
      format.json { head :no_content }
    end
  end   
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_institute
      @institute = Institute.find(params[:id])
    end
    
    # Below - Sets admin as current admin
    def set_admin
      @admin = current_admin
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def institute_params
      params.require(:institute).permit(:name, :description, :category, :email)
    end
end
