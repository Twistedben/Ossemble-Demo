class CommentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
  
#  def new?
    
#  end
  def reply?
    user_is_present? 
  end 
  def create?
    user_is_present? 
  end 
  def edit? 
    user_is_owner_and_present? || is_mod?
  end 
  def update? 
    user_is_owner_and_present? || is_mod?
  end 
  def destroy? 
    user_is_owner_and_present? || is_mod?
  end 
  def upvote?
    user_is_present? || admin_is_present?
  end 
  
end
