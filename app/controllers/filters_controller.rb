class FiltersController < ApplicationController
  # Controller for filter panel 
  # Below - Before action that sets up city from params
  before_action :set_city
  
  # Below -  Complaint category filter for AJAX
  def category_filter 
    respond_to do |format|
			format.js # Calls category_filter.js.erb in follows view folder AJAX Code.
		end # Respond to block
  end   
  
  # Below -  Complaint category filter for AJAX
  def process_filter 
    respond_to do |format|
			format.js # Calls process_filter.js.erb in follows view folder AJAX Code.
		end # Respond to block
  end   
  
  private 
  
  # Below -  Sets city from params
  def set_city 
     @city = City.friendly.find(params[:city_id])
  end   
  
end