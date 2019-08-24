class AdminChatroom < ApplicationRecord
  
  # Below - FRIENDLYID: Adding FriendlyID to this model so chatroom name is URL instead of ID. 
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
  # Below -  Generates the slug based on chatroom name
    def slug_candidates
      [
        :name,
        [:name, self.city.name],
        [:name, self.city.name, :id]
      ]
    end 
  # Below - Determines if there's a blank or new Record to assign a slug to.
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end
  
  # Below - Plain validation of BLANK  
  validates :name, presence: { message: 'A chatroom must have a name' }
  validates_length_of :description, :minimum => 1, :maximum => 255, 
     :too_long => "Please write a shorter description as the maximum character length is 255, which is about 40 words.", 
     :allow_blank => true
  validates :workplace_id, presence: { message: 'A chatroom must have an associated workplace' }
  
  belongs_to :workplace
  has_one :city, through: :workplace
  has_many :chatroom_admins
  has_many :admins, through: :chatroom_admins
  has_many :admin_messages
  
end
