class VisitorsController < ApplicationController
# Main controller for guest pages, about pages, landing pages, basically any page without /users or /cities prefix. 
  # Below - Before action that sets the city for guest pages, and visitor pages.
  #before_action :set_city

  
  def index
  end
  
  def contact_us 
    if is_guest?
      flash[:alert] = "You must login to your profile in order to contact us. Please login or create a profile, or <a class='title_link' href='mailto:support@ossemble.com'>email us</a>."
      redirect_to new_user_session_path
    end 
  end 
  
  def about
    
  end
  
  def inspiration
    
  end
  
  def team
    
  end
  
  def community_score
  
  end  
  
  def reputation
  
  end
  
  def executive_summary
 
  end 
  
  def city_landing_page
  end 
  
  def policies
    
  end 
  
  def feedback
    
  end
  
  def features
    
  end
  
  def love
    redirect_to root_path
  end 
  
  def complaints
    
  end 
  
  def forum 
    
  end 
  
  def faq 
    
  end
  
  private 
 
end
