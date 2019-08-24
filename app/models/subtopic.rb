class Subtopic < ApplicationRecord
# Main model for Subtopic feature inside of Ossembly. Subtopic is beneath Topic beneath Ossembly, Posts < Subtopics, Subtopics < Subtopics, Subtopics < Ossembly

# Begin - SCOPES: Scopes for Subtopics.
  
# End - SCOPES: Scopes for Subtopics.

# Begin - Gems and acts_as setups. 
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of users' comments
  include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  tracked
  # Below - FRIENDLYID: Adding FriendlyID to Subtopics URL so Subtopic Name is URL (/subtopic/furry-friends) instead of ID. 
    extend FriendlyId
    friendly_id :name, use: [:slugged, :finders]
    # Below - Determines if there's a blank or new Record to assign a slug to.
    def should_generate_new_friendly_id?
      new_record? || slug.blank?
    end
  # Below - PUNCHABLE: Allows Acts_as_punchable for subtopics from the punching_bag gem.
    # Sets up subtopics for punching bag hits.
    acts_as_punchable
     # ACTS AS FOLLOWABLE gem helps user follow the corresponding category
    #acts_as_followable
# End - Gems and acts_as setups.

# Begin - VALIDATIONS: Validations for Subtopics Table.
  
# End - VALIDATIONS: Validations for Subtopics Table.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations for Subtopics table.   
  # Below - Associates Subtopic with Topic using a one to many relation: (Topics has many subtopics)
  belongs_to :topic 
  # Below - Associates Subtopic with User using a one to many relation: (User doesn't have an end association just in case subtopic is created without a user)
  belongs_to :user, optional: true
  # Below - Associates Subtopic with City using a one to many relation: (City has many subtopics)
  belongs_to :city
  # Below - Associates Subtopics with Posts, using a many to one relation. If a subtopic is destroyed, so are its related posts: (Post belongs_to subtopic)
  has_many :posts, class_name: "Post", foreign_key: "subtopic_id", dependent: :destroy
  # Below - Attaches Active Storage to subtopics as a has many relationship. If a subtopic is destroyed, so are its attached images.
  has_many_attached :images, dependent: :destroy

# End - ASSOCIATIONS: Many/Belongs To/One Relations for Subtopics table.   

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks.
  # Below -  Creates subtopcis for a new city. Is called from topic.rb model after the topics are created, called from city.rb model.
  def create_subtopics(city, lets_talk, good_vibes, city_affairs) 
     if city.subtopics.count >= 12
       puts "#{city.name} City already has #{city.subtopics.count} subtopics."
     else # Subtopics don't already exist, so they're created.
       new_city_subtopics = city.subtopics.build([
          {
            name: "Help Me Out",
            description: "Post about anything you need help with amongst the boundaries of your city, ranging from accomplishing a common goal to finding your missing dog.",
            topic_id: lets_talk.id,
          },
          {
            name: "Business Buzz",
            description: "Post about your business, local businesses, new businesses, small businesses. Its all of your business!",
            topic_id: lets_talk.id,
          },
          {
            name: "Grinds My Gears",
            description: "Doesn't that just grind your gears? Vent and rant about the things that bug you concerning your city.",
            topic_id: lets_talk.id,
          },
          {
            name: "Sports",
            description: "What's your take on local sports? High school teams, peewee football?",
            topic_id: lets_talk.id,
          },
          {
            name: "Good News",
            description: "Heard something about your city that just makes you feel good about it? Or something inside your city that uplifts? Spread the good news!",
            topic_id: good_vibes.id,
          },
          {
            name: "Furry Friends",
            description: "You love your cat or dog. We do, too. Post about the cute creatures of your city.",
            topic_id: good_vibes.id,
          },
          {
            name: "City Snaps",
            description: "Share your favorite picture of your city or anything related to it.",
            topic_id: good_vibes.id,
          },
          {
            name: "Local Historian",
            description: "Your city has a lot of history. Share it and interesting stories you find buried in the past!",
            topic_id: good_vibes.id,
          },
          {
            name: "Ballots",
            description: "Ballots for your local city.",
            topic_id: city_affairs.id,
          },
          {
            name: "Events",
            description: "Events in your city: townhalls, zoning, official meetings, etc..",
            topic_id: city_affairs.id,
          },
          {
            name: "City Improvements",
            description: "Post about ways and means to improve you city, ranging from governmental to community reforms..",
            topic_id: city_affairs.id,
          },
          {
            name: "Schools",
            description: "Discuss the happenings within your local school district. Policies, teachers, curriculum, etc..",
            topic_id: city_affairs.id,
          }
          ])
        city.subtopics << new_city_subtopics
        puts "Created #{new_city_subtopics.count} #{city.name} Ossembly Forum Subtopics. Created Subtopics: #{new_city_subtopics.pluck(:name)} "
     end 
  end   

# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks .

end
