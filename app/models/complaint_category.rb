class ComplaintCategory < ApplicationRecord
# Main Model for complaint_categories which assigns complaints' a category and a deadline within the table. 

# Begin- SCOPES: Scopes for Complaint Category
  scope :other_categories, -> { where(category: "Other") }
  
# End - SCOPES: Scopes for Complaint Category
  

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations for ComplaintCategory.   
  # Below - Sets up Many to One relationship between ComplaintCategory and Complaints table (Complaints belongs to ComplaintCategory.)
  has_many :complaints, class_name: "Complaint", foreign_key: "complaint_id"
  
# End - ASSOCIATIONS: Many/Belongs To/One Relations for ComplaintCategory.
  
# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for ComplaintCategory Model.
  
# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for ComplaintCategory Model.
end
