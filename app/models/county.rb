class County < ApplicationRecord
# Main Model for Counties

# Begin - SCOPES: Scopes for records.

# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 
  # Below - FRIENDLYID: Adding FriendlyID to Counties.
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]
  # Below - Determines if there's a blank or new Record to assign a slug to.
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end

# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  # Below - Plain validation of a states' association with a county.  
  validates :state_id, presence: { message: 'A county must be affiliated with a state.' }
  # Below - Plain validation of a county's name.  
  validates :name, presence: { message: 'A county must have a name.' }
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  
# Begin - ASSOCIATIONS: All Associations for model Table to other tables.
  # Below - Associates a one to many relationship with states. (states has many counties)  
  belongs_to :state
  # Below - Associates a many to one relationship with Counties and Cities. (Cities belongs to County) 
  has_many :cities, class_name: "City", foreign_key: "county_id"
  # Below - Associates a many to one relationship with Counties and Admins. (Admins belongs to County) 
  has_many :admins, class_name: "Admin", foreign_key: "county_id"
  # Below - Associates Counties with users through City. (Users belongs_to :county, :through :city)
  has_many :users, :through => :cities
  # Below - Associates an admin county account with county. Do something like: where county: true
  #has_one :county_admin, class_name: "Admin", foreign_key: "county_id", 
  # Below - Associates counties with petitions, through cities.   
  has_many :petitions, :through => :cities
# End - ASSOCIATIONS: All Associations for model Table to other tables.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  
  
end
