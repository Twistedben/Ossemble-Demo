class ZipCode < ApplicationRecord
# Main Model for Following resources and :follows table. Links up with Acts_as_follower gem and the follows_controller.rb controller.
  
# Begin - SCOPES: Scopes for Posts.

# End - SCOPES: Scopes for Posts.

# Begin - VALIDATIONS: Validations for City Table.
  # Below - Ensures a city is associated with a zipcode.
  validates :city_id, presence: { message: 'A zipcode must have a city associated with it.' }
  # Below - Ensures a zipcode's number is unique and not already added per the scope of City ID since some cities cross zipcodes.
  validates_uniqueness_of :zip, scope: :city_id, presence: { message: 'This zipcode already exists for this city. Ensure you entered it correctly.' }

# End - VALIDATIONS: Validations for City Table.

  
# Begin - ASSOCIATIONS
  # Below - Associates BLANK as a one to BLANK relationship with BLANK. (BLANK has BLANK)  
  
  # Below - Associates BLANK as a one to BLANK relationship with BLANK. (BLANK has BLANK)  
  belongs_to :city
  # End - ASSOCIATIONS


# Begin - CUSTOM METHODS
  # Below -  
  
# End - CUSTOM METHODS

end
