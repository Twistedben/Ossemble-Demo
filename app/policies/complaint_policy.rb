class ComplaintPolicy < ApplicationPolicy
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
  # Authorizarion for complaint actions is done inside the controller using custom code for admin.
  
end