class CityScoresController < ApplicationController
# Main CityScore Controller.
  before_action :set_city_score, only: [:show, :edit, :update, :destroy]

  def index
    @city_scores = CityScore.all
  end

  def show
  end

  def new
    @city_score = CityScore.new
  end

  def edit
  end

  def create
    @city_score = CityScore.new(city_score_params)

    respond_to do |format|
      if @city_score.save
        format.html { redirect_to @city_score, notice: 'City score was successfully created.' }
        format.json { render :show, status: :created, location: @city_score }
      else
        format.html { render :new }
        format.json { render json: @city_score.errors, status: :unprocessable_entity }
        puts "Failed"
      end
    end
  end

  # PATCH/PUT /city_scores/1
  # PATCH/PUT /city_scores/1.json
  def update
    respond_to do |format|
      if @city_score.update(city_score_params)
        format.html { redirect_to @city_score, notice: 'City score was successfully updated.' }
        format.json { render :show, status: :ok, location: @city_score }
      else
        format.html { render :edit }
        format.json { render json: @city_score.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /city_scores/1
  # DELETE /city_scores/1.json
  def destroy
    @city_score.destroy
    respond_to do |format|
      format.html { redirect_to city_scores_url, notice: 'City score was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_city_score
      @city_score = CityScore.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def city_score_params
      params.require(:city_score).permit(:score, :city_id)
    end
end
