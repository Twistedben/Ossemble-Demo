class Department < ApplicationRecord
# Ossemble's Main Department Model for Departments for admins.

# Begin - Gems and acts_as setups. 
  # Below - FRIENDLYID: Adding FriendlyID to Departments URL so the individual Department Name shows under city URL (/cities/lakewood/City-hall) instead of ID. 
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]
  # Below - Determines if there's a blank or new Record to assign a slug to.
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end

# End - Gems and acts_as setups. 

# Begin - Scopes for Departments. 
 
# End - Scopes for Departments.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.

# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  
# Begin - ASSOCIATIONS: All Associations of Department Table to other tables (One to Many - City_score & One to Many - Department_Category & Has Many and Belongs - Reviews).
 
# End - ASSOCIATIONS: All Associations of Department Table to other tables.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Department Model.

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Department Model.

end # End - Main Department Model for Departments.
