class Location < ApplicationRecord
# Begin - Gem and acts_as setup.
  # Below - MAINSTREET: Sets up Mainstreet for location table
=begin 
  acts_as_address
  # Begin - GEOCODER: Sets up Geocoder gem for location
    geocoded_by :address
    after_validation :geocode
    def address
      [street, city, state, zip_code].compact.join(', ')
    end
  # End - GEOCODER:
# End - Gem and acts_as setup.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations
  # Below - Plain validation of user association  
  validates :user_id, presence: true
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations
  
# Begin - ASSOCIATIONS: All Associations for Table to other tables.
    # Below - Associates Location as a one to one relationship with Users. (User has one location)  
    belongs_to :user
# End - ASSOCIATIONS:

# Begin -  CUSTOM METHODS: Custom methods for Location
  
# End -  CUSTOM METHODS:

# Begin -  CALLBACKS: Custom callbacks for Location

# End -  CALLBACKS:

=end
end
