class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  # Below - Counts all comments associated with id (ID: Post, Complaint, WUL, Reviews, Petitions) and subject that matches the class. So Comment (parent_id: 9, subject: "Petitions")
  def count_comments
    count_comments = Comment.where(parent_id: self.id, subject: "#{self.class.to_s}") 
    return count_comments.count 
  end 
  # Below - Returns all comments associated with subject (ID: Post, Complaint, WUL)
  def list_comments
    list_comments = Comment.where(parent_id: self.id)
    return list_comments
  end 
end
