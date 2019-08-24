class DepartmentsController < ApplicationController
# Main departments controller.
  # Below - Sets department for only actions listed in square brackets
  before_action :set_department, only: [:show, :edit, :update, :destroy]
  # Below - Sets city for every action
  before_action :set_city

  def index
    # Begin - Sorting logic for departments. 
    if params[:sort_by] == "score"
      @departments = @city.departments.order('score DESC')
    elsif params[:sort_by] == "name"
      @departments = @city.departments.order('name')
    elsif params[:sort_by] == "reviews"
      # Below - Orders by Review count, but filters out departments not yet reviewed.
        # PROGRAMMERS NOTE: Find a way to have 0 review departments not filtered out.
      @departments = @city.departments.joins(:reviews).group('departments.id, department_id').order('COUNT(reviews.id) DESC') 
    elsif params[:sort_by] == "trending"
      @departments = @city.departments.joins(:punches).group('departments.id').order('COUNT(punches.id) DESC')
    else 
      @week_departments = @city.departments.most_hit(1.week.ago, 10)
      @month_departments = @city.departments.most_hit(1.month.ago, nil)   
      @departments = @city.departments.joins(:punches).group('departments.id').order('COUNT(punches.id) DESC')
    end 
    # End - Sorting logic for departments. 

    # Begin - Finding the average score for the given Department according to Reviews :score field, assigning it to @review_avg.
     # @ordered_hash = Review.group('department_id').average('score')
     # @keys = @ordered_hash.keys
    #  @review_avg = Review.where(:department_id=>@keys).uniq {|x| x.department_id}
    # End - Finding the average score for the given Department according to Reviews :score field, assigning it to @review_avg.

  end

  def show
    # Before_Action setting @department.
    # Below - adds punch counter to department.
    @department.punch(request)
    # Below - Creates object for all reviews belonging to given @Department.
    @department_reviews = @department.reviews 
    # Begin - Finding the average score for the given Department according to Reviews :score field, assigning it to @review_avg.
     # @ordered_hash = Review.group('department_id').average('score')
     # @keys = @ordered_hash.keys
     # @review_avg = Review.where(:department_id=>@keys).uniq {|x| x.department_id}
    # End - Finding the average score for the given Department according to Reviews :score field, assigning it to @review_avg.
   # @city_department = Department.find(params[:department_id])
  end

  # GET /departments/new
  def new
    @department = Department.new
  end

  # GET /departments/1/edit
  def edit
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = @city.departments.build(department_params)

    respond_to do |format|
      if @department.save
        format.html { redirect_to @department, notice: 'Department was successfully created.' }
        format.json { render :show, status: :created, location: @department }
      else
        format.html { render :new }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to @department, notice: 'Department was successfully updated.' }
        format.json { render :show, status: :ok, location: @department }
      else
        format.html { render :edit }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    @department.destroy
    respond_to do |format|
      format.html { redirect_to departments_url, notice: 'Department was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
# Begin - Filters for Departments. Routes set up in Collection Do Block. Scopes grabbed from Department.rb model.
  # Below - Filters for Government departments from government scope.
    def government 
      if params[:sort_by] == "score"
        @departments = @city.departments.government.order('score DESC')
        render action: :index
      elsif params[:sort_by] == "name"
        @departments = @city.departments.government.order('name')
        render action: :index
      elsif params[:sort_by] == "reviews"
        @departments = @city.departments.government.joins(:reviews).group('departments.id, department_id').order('COUNT(reviews.id) DESC') 
        render action: :index
      elsif params[:sort_by] == "trending"
        @departments = @city.departments.government.joins(:punches).group('departments.id').order('COUNT(punches.id) DESC')
        render action: :index
      else 
        @departments = @city.departments.government.joins(:punches).group('departments.id').order('COUNT(punches.id) DESC')
        render action: :index
      end 
    end   
  # Below - Filters for School departments from schools scope.   
    def schools 
      if params[:sort_by] == "score"
        @departments = @city.departments.schools.order('score DESC')
        render action: :index
      elsif params[:sort_by] == "name"
        @departments = @city.departments.schools.order('name')
        render action: :index
      elsif params[:sort_by] == "reviews"
        @departments = @city.departments.schools.joins(:reviews).group('departments.id, department_id').order('COUNT(reviews.id) DESC') 
        render action: :index
      elsif params[:sort_by] == "trending"
        @departments = @city.departments.schools.joins(:punches).group('departments.id').order('COUNT(punches.id) DESC')
        render action: :index
      else 
        @departments = @city.departments.schools.joins(:punches).group('departments.id').order('COUNT(punches.id) DESC')
        render action: :index
      end 

    end 
  # Below - Filters for parks departments from parks scope.
    def parks 
      if params[:sort_by] == "score"
        @departments = @city.departments.parks.order('score DESC')
        render action: :index
      elsif params[:sort_by] == "name"
        @departments = @city.departments.parks.order('name')
        render action: :index
      elsif params[:sort_by] == "reviews"
        @departments = @city.departments.parks.joins(:reviews).group('departments.id, department_id').order('COUNT(reviews.id) DESC') 
        render action: :index
      elsif params[:sort_by] == "trending"
        @departments = @city.departments.parks.joins(:punches).group('departments.id').order('COUNT(punches.id) DESC')
        render action: :index
      else 
        @departments = @city.departments.parks.joins(:punches).group('departments.id').order('COUNT(punches.id) DESC')
        render action: :index
      end 
    end   
  # Below - Filtered map for Government Departments.
    def government_map
      @departments = @city.departments.government
      render action: :department_map
    end
  # Below - Filtered map for Schools Departments.
    def schools_map
      @departments = @city.departments.schools
      render action: :department_map
    end
  # Below - Filtered map for Parks Departments.
    def parks_map
      @departments = @city.departments.parks
      render action: :department_map
    end
# End - Filters for Departments. Routes set up in Collection Do Block. Scopes grabbed from Department.rb model.
  # Below - Controller method for /department/map 
    def department_map
      @departments = @city.departments.all
      @government_departments = @city.departments.government # Setups up an instance variable for all government departments.
      @school_departments = @city.departments.schools # Setups up an instance variable for all school departments.
      @park_departments = @city.departments.parks # Setups up an instance variable for all parks departments.
    end 



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      @department = Department.friendly.find(params[:id])
    end
    
    def set_city
      @city = City.friendly.find(params[:city_id])
    end

    def department_params
      params.require(:department).permit(:name, :city_id, :score, :city_score_id, :latitude, :longitude, :timestamps)
    end
   
end
