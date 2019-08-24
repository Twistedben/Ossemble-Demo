class Admin < ApplicationRecord
  # Below - Added by Chargbee_rails gem. Allows api calls 
  include ChargebeeRails::Customer
  serialize :chargebee_data, JSON
# Main admin model for Admins Table. References Cities

# Begin - SCOPES: Scopes for records.
  # Below - Scopes admins by returning just super admin  
  scope :super_admins, -> { where(:super_admin => true)}

# End - SCOPES: Scopes for records.
# Begin - Gems and acts_as setups. 
  # Below - Devise setup for admins model.
  # Not used: , :lockable,  and :omniauthable and , :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, 
         :validatable, :lockable #, :confirmable
  # Below - FRIENDLYID: Adding FriendlyID to Counties.
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
  # Below -  Generates the slug based on user's name field and id at the end
    # Below -  Generates the slug based on user's name field and id at the end
    def slug_candidates
      unless self.first_name.blank? || self.last_name.blank?
        if self.name.blank? 
          self.set_full_name
          self.slug_candidates
        else
            [
              :name,
              [:name, :id],
            ]
        end
      end
    end 


  # Below - Determines if there's a blank or new Record to assign a slug to.
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end
  # Below - VOTABLE: Allows Acts_as_Votable for Users.
    acts_as_voter
# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  # Begin - EMAIL VALIDATION: Validation method that ensures an admin account's email fits with the recognized emails for that city.
    def check_email_validity
      unless self.super_admin?  # Won't run if the admin is a super admin. 
        unless self.visitor? # Won't run email validation of city if the admin is set as visitor which is set by workplace via the invite.
          if !self.email.include? "#{self.institute.split_email_domain}"
            errors.add(:email, "address doesn't match the official email domain for this Workplace. If you believe this to be an error, please contact us at: support@ossemble.com ")
            return true
          end
        end 
      end 
    end
  # End - EMAIL VALIDATION:
    # Below - Custom Validation for First name  
  def validate_first_name
    if self.first_name.blank?
      errors.add(:first_name, "must be provided.")
      return true
    end
  end   
  # Below - Custom Validation for last name  
  def validate_last_name
    if self.last_name.blank?
      errors.add(:last_name, "must be provided.")
      return true
    end
  end   
  
  #PAssword and email is validated by Devise
  validate  :validate_first_name
  validate  :validate_last_name
  validates :phone_number, presence: { message: "must be provided." }
  validates :organization, presence: { message: "or department that you belong to must be provided." }
  # Below - Custom validation ensuring the email belongs to the respective city as anofficial email address
  validate :check_email_validity, on: :create 
# End - VALIDATIONS: Additional validations of DB field attributes presence at Model-level and Character Limitations.
  
# Begin - ASSOCIATIONS: All Associations of model Table to other tables.
  # Below - Associates a one to one relationship with Admins and Cities. (City has_many admins) 
  #belongs_to :city, optional: true
  # Below - Associates a one to one relationship with Admins and Institutes. (Institute has_many admins) 
  belongs_to :institute, optional: true
  # Below - Associates BLANK as a one to BLANK relationship with BLANK. (BLANK has BLANK)  
  belongs_to :department, class_name: "WorkplaceDepartment", foreign_key: "workplace_department_id", optional: true
  # Below - Associates a one to many relationship with Admins and County. (County has many admins) 
  #has_one :county, through: :city
  # Below - Associates a user with an admin so admins can post and have a basic profile: (User has one admin)  
  #has_one :city_user, -> { where.not(user_id: nil) }, class_name: "User", foreign_key: "user_id"
  # Below - Associates Admins as a has one to one relationship with Subscriptions. (Subscription belongs to Admin)  
  has_one :subscription, class_name: "Subscription", foreign_key: "admin_id"
  # Below - Associates admins with their library (admin_library belongs_to :admin)
  has_one :library, class_name: "AdminLibrary", foreign_key: "admin_id", dependent: :destroy
  # Below - Allows calling for Admin.endorsements to get all upvotes, otherwise .upvotes will call Acts_as_votable.
  has_many :endorsements, class_name: "ActsAsVotable::Vote", foreign_key: "voter_id", dependent: :destroy
  # Below - Associates comments with admins. (Comments belong to admin)  
  has_many :comments, dependent: :destroy
  # Below - Associates admins with activities so @admin.activities can be called.
  has_many :activities, :through => :city,  class_name: "PublicActivity::Activity", foreign_key: "recipient_id"
  # Below - Associates admins as a has many to one relationship with Contacts. (Contacts belong to Admins)  
  has_many :contacts, class_name: "Contact", foreign_key: "admin_id", dependent: :destroy
  # Below - Associates admins as a many to one relationship with WorkplacePost. (WorkplacePost belongs to admin)  
  has_many :posts, class_name: "WorkplacePost", foreign_key: "admin_id", dependent: :destroy
  # Below - Associates admins as a many to many relationship with WorkplaceAdmin, a join table. (WorkplaceAdmin belongs to admin)  
  has_many :workplace_admins, dependent: :destroy
  # Below - Associates admins as a many to many relationship with WorkplaceAdmin, a join table. (WorkplaceAdmin belongs to admin)  
  has_many :map_posts, class_name: "WorkplaceMapPost", foreign_key: "admin_id", dependent: :destroy
  # Below - Associates admins as a many to many relationship with Workplaces, through a join table of WorkplaceAdmin. (Workplaces has many admins)  
  has_many :workplaces, through: :workplace_admins
  # Below - Associates admins as a many to many relationship with Notifications  
  has_many :notifications, class_name: "Notification", foreign_key: "recipient_id", dependent: :destroy
  # Below - Associates admins as a has many to one relationship with Invites. (Invite (invitations) belongs to Admins)  Admin who received the invite.
  has_many :invitations, class_name: "Invite", foreign_key: "recipient_id", dependent: :destroy
  # Below - Associates admins as a has many to one relationship with Invites. (Invite (sent_invites) belongs to Admins)  Admin who sent the invite.
  has_many :sent_invites, class_name: "Invite", foreign_key: "sender_id", dependent: :destroy
  # Begin - Chatroom and action cable associations
    has_many :chatroom_admins, dependent: :destroy
    has_many :admin_chatrooms, through: :chatroom_admins
    has_many :admin_messages, dependent: :destroy
  # End - Chatroom and action cable associations  
  # Below - Associates with library uploads in a many to one relationship (library_uploads belong_to :admin) 
  has_many :uploads, class_name: "LibraryUpload", foreign_key: "admin_id", dependent: :destroy
  # Below - Associates with Library entries through the has one association with admin_library
  has_many :entries, :through => :library
  # Below - Associates Library entries as a has many to one optional relationship with admins to share entries with a receiver. (library_entry belongs to admin as sender, optional: true)  
  has_many :sent_entries, class_name: "LibraryEntry", foreign_key: "sender_id"
  # Below - Associates Library entries as a has many to one optional relationship with admins to receiver shared entries from sender. (library_entry belongs to admin as receiver, optional: true)  
  has_many :received_entries, class_name: "LibraryEntry", foreign_key: "receiver_id"
  # Below - Allows an attached avatar image to admins via Amazon S3.
  has_one_attached :avatar, dependent: :destroy
# End - ASSOCIATIONS: All Associations of model Table to other tables.

# Begin - MODEL METHODS: Custom Model Methods.

  # Below -  Returns the admin's main workplace
  def main_workplace 
    self.institute.main_workplace
  end   
  
#  def self.to_csv
#    attributes = %w{id email first_name last_name}
#    CSV.generate(headers: true) do |csv|
#      csv << attributes
#      all.each do |admin|
#        csv << attributes.map{ |attr| admin.send(attr) }
#      end
#    end
#  end
#  
#  # Below - Method called from rake task for CSV importing for workplace member invites, import.rake.
#  def self.assign_from_row(row)
#    admin = Admin.where(email: row[:email]).first_or_initalize
#    admin.assign_attributes row.to_hash.slice(:first_name, :last_name)
#  end
  
  # Below - Check is the admin is a guest user  
  def is_guest_admin?
    return true if self.first_name == "Guest" 
  end   
  
  # Below -  Returns on an admin call with a provided workplace the record of the admin from the :workplace_admins table, like permission level, workpalce and when they joined.
  def return_workplace_membership(workplace)
    workplace.members.find_by_admin_id(self.id)
  end   
  
  # Below - A method call, to return true or false, on an admin call to check if the admin belongs to the passed in workplace. 
  def belongs_to_workplace?(workplace) 
    if workplace.admins.include?(self)
      return true
    else 
      return false
    end 
  end   
  
  # Below -  Ensures admin belongs to a workplace. This is called primarily on application.html.erb whether to render the side panel or not.
  def belongs_to_a_workplace? 
    if self.workplaces.empty?
      return false
    else
      return true
    end
  end   
# End - MODEL METHODS: Custom Model Methods.


# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  
  after_create_commit :subscribe_to_mailerlite, :set_full_name, :create_admin_library#, :set_super_admin #, :create_city_user
  after_create_commit :create_subscription_plan, if: :is_super_admin?
  # If an admin changes their first or last name, it will update the :name attribute
  after_commit :update_full_name, on: :update 
  
  # Below - Called after admin signs up in a create commit callback if the institute has a Institute Workplace
  def join_institute_workplace
    self.workplaces.push(self.institute.main_workplace) unless self.institute.main_workplace.admins.include?(self) # Pushes admin into city workplace unless they're already a member
  end   
  
  # Below -  Creates a reserved library for an admin after they signup and create a profile.
  def create_admin_library 
    library = AdminLibrary.new(name: "#{self.name} Archive", admin_id: self.id)
    library.save
  end   

  # Below -  An If Conditional check if admin is a super admin. Runs before after create callback on admin's setup_city_workplace
  def is_super_admin?
    if self.super_admin?
      return true
    else 
      return false
    end 
  end   
  
  # Below -  An Unless Conditional check if admin's city workplace exists. Runs before after create callback on admin's setup_city_workplace
  def has_institute_workplace? 
    if self.institute.nil?
      return false 
    else 
      if self.institute.main_workplace.nil? # Admin's city doesn't have a city workplace
        return false 
      else 
        if self.institute.main_workplace.activated == false 
          return false 
        else 
          return true
        end
      end
    end
  end   
  
  # Below - 
  def has_institute?
    if self.institute.nil?
      return false
    else 
      return true
    end 
  end
  
  # Below - Combines newly created admin's first name and last name into the ":name" attribute.
  def set_full_name
    if self.name.blank?
      self.name = "#{self.first_name} #{self.last_name}".strip
    else # This exists for Admin slave user creation.
      return false
    end
  end
  
  # Below - Runs when admin updates their name to generate the new :name attribute field.
  def update_full_name
    # Below - Checks if the name changed or not.
    if self.name != "#{self.first_name} #{self.last_name}".strip 
      # Below - If the name changed, update the change.
      self.name = "#{self.first_name} #{self.last_name}".strip
    end 
  end
 
  # Below -  Creates default free plan for super admins.
  def create_subscription_plan 
    if self.subscription.nil?
       Subscription.create(admin_id: self.id )
    else 
      puts "Subscription already created for admin"
    end   
  end   
  
  # Below -  Called in an after create action to subscribe the admin/city to mailerlite only in production.
  def subscribe_to_mailerlite
    if self.valid? && Rails.env.production?
      @admin = self 
      info = { email: "#{@admin.email}", name: "#{@admin.first_name} #{@admin.last_name}", "fields": { country: "US"}}
      MailerLite.create_group_subscriber(8244102, info)
    end
  end 
  
  
# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.


end
