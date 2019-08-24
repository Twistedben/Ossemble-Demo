class Institute < ApplicationRecord
# Main Model for Institutes, parent of nearly everything and workplaces.
 
  # Below - Added by Chargbee_rails gem. Allows api calls 
  include ChargebeeRails::Customer
  serialize :chargebee_data, JSON

# Begin - SCOPES: Scopes for records.
  # Below - Orders created to the top of the list in descending order.
  #default_scope { order(created_at: :desc)}
  
# End - SCOPES: Scopes for records.

# Begin - Gems and acts_as setups. 
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of creation of records
  #include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  #tracked
  # Below - FRIENDLYID: Adding FriendlyID to this model so BLANK is URL instead of ID. 
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
    # Below -  Generates the slug based on BLANK
  def slug_candidates
    [
      :name,
      [:name, :category],
      [:name, :category, :id]
    ]
  end 
  # Below - Determines if there's a blank or new Record to assign a slug to.
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end
  # Below - ACTS_AS_VOTABLE - Acts_as_votable gem to allow upvotes for this model.
  #  acts_as_votable
  # Below - PUNCHABLE: Allows Acts_as_punchable (trending) for BLANK from the punching_bag gem.
  #  acts_as_punchable

# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level, Uniqueness and Character Limitations.
  
  # Begin - CUSTOM VALIDATIONS: 
  
  # End - CUSTOM VALIDATIONS: 
  
  # Begin - RUBY VALIDATIONS: 
    validates :name, presence: { message: "Please enter a identifiable name for the Workplace." }
    validates :description, presence: { message: "Please enter a short description for the Workplace." }, allow_blank: true
    validates :email, presence: { message: "Please enter the email domain to assign to this Workplace." }
    validates :category, presence: { message: "Please select a Category for this Workplace." }
  # End - RUBY VALIDATIONS: 
  
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations.   
  
  # Below - Allows a main workplace to be called for an institute  
  has_one :main_workplace, -> { where(is_main: true) }, class_name: "Workplace", foreign_key: "institute_id"
  # Below - Associates as a has one to one relationship with subscriptions. (subscriptions belongs to institute)  
  has_one :subscription
  # Below - Associates as a has one to one relationship with subscriptions. (subscriptions belongs to institute)  
  has_one :plan, through: :subscription
  # Below - Associates a many to one association to Admin. (Admin belongs to institute)
  has_many :admins
  # Below - Allows institutes to have super_admins for workplace creation. 
  has_many :super_admins, -> { where(super_admin: true) }, class_name: "Admin", foreign_key: "institute_id"
  # Below - Associates as a has many to one relationship with workplaces. (Workplaces belongs to institute)  
  has_many :workplaces, dependent: :destroy
  # Below - Associates cities as a has many relationship with posts, going through the workplaces table which holds the institute_id. (workplace posts belongs to institute through workplaces)
  has_many :posts, through: :workplaces
  # Below - Associates cities as a has many relationship with map_posts, going through the workplaces table which holds the institute_id. (workplace map Posts belongs to institute through workplaces)
  has_many :map_posts, through: :workplaces
  
# End - ASSOCIATIONS: Many/Belongs To/One Relations. 

# Begin - METHODS: Custom Methods and model calls.
  
  # Below - Splits the institute email that the admin is affiliated with into a string from @ on to check email validity for admin creation vrs email domain.  
  def split_email_domain
    return self.email.split('@')[1]
  end   
  
  # Below -  Checks to see if Institute Main Workplace exists.
  def has_main_workplace? 
    if self.main_workplace.nil? # City doesn't have a city workplace
      return false 
    else 
      return true
    end
  end   
  # Below - Does the institute have a super admin. This is used in Admins Registration New for determining if there should be a super admin assigned to an instute that doesn't have one like from an institute created in a seed file.  
  def has_super_admins? 
    if self.super_admins.count > 0
      return true 
    else
      return false
    end 
  end   
  # Below - Returns the citie's email domain for email calidation. 
  def return_email_domain 
    return "@" + self.email.split('@')[1]
  end   
  
  # Below -  Creates a new Workplace for an institute when one is called on Institute with an admin as params. Can also be called from admin registration create if city workplace doesn't exist.
  def setup_main_workplace(admin)
    institute = admin.institute
    new_main_workplace = institute.workplaces.create(name: "#{self.name} Channel", description: "Main Channel for #{self.name}. This first Channel is automatically provided for employees to collaborate within it.", is_main: true)
    puts "New Main Workplace was created: #{new_main_workplace.inspect}"
  end 

  # Checks if institute has a subscription and is called as an Unless condition in create_subscription callback below.
  def has_subscription?
    if self.subscription.nil?
      return false
    else 
      return true
    end
  end
# End - METHODS: Custom Methods and model calls.

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.


# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
end
