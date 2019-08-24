class Topic < ApplicationRecord
# Main model for Topic feature inside of Ossembly. Topic is the highest class beneath Ossembly, Posts < Subtopics, Subtopics < Topics, Topics < Ossembly

# Begin - SCOPES: Scopes for Topics.
  
# End - SCOPES: Scopes for Topics.

# Begin - Gems and acts_as setups. 
  # Below - FRIENDLYID: Adding FriendlyID to Topics URL so Topic Name is URL (/topics/good-vibes) instead of ID. 
    extend FriendlyId
    friendly_id :name, use: [:slugged, :finders]
    # Below - Determines if there's a blank or new Record to assign a slug to.
    def should_generate_new_friendly_id?
      new_record? || slug.blank?
    end
# End - Gems and acts_as setups.
 # ACTS AS FOLLOWABLE gem helps user follow the corresponding category
  #acts_as_followable

# Begin - VALIDATIONS: Validations for Topics Table.
  
# End - VALIDATIONS: Validations for Topics Table.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations for Topics table.   
  # Below - Associates Topic with city using a many to one relation: (Cities has many topics)
  belongs_to :city 
  # Below - Associates Topics with subtopics, using a many to one relation: (Subtopics belongs_to topic)
  has_many :subtopics, class_name: "Subtopic", foreign_key: "topic_id", dependent: :destroy
  # Below - Associated Topics with posts through subtopics so that Topic.posts can be called.
  has_many :posts, :through => :subtopics
# End - ASSOCIATIONS: Many/Belongs To/One Relations for Topics table.   

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Topic Model.
 
# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for Topic Model.

end
