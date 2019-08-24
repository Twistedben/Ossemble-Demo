class CityReviewPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  
  def new? 
    user_is_present? 
  end 
  def create?
    user_is_present? 
  end 
  def edit? 
    user_is_owner_and_present? 
  end 
  def update? 
    user_is_owner_and_present? 
  end 
  def destroy? 
    user_is_owner_and_present?
  end 
  def upvote?
    user_is_present? 
  end 

end
