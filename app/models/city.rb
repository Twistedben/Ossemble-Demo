class City < ApplicationRecord
# Ossemble's main City Model for cities that users are assocaited with.

# Begin - FRIENDLYID: Adding FriendlyID to Cities URL so City Name is URL (/cities/lakewood) instead of ID. 
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of users' comments
  include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  tracked
  # PROGRAMMERS NOTE: Eventually when duplicate city names occur, we may need to preceed the city's name with the County Name.
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
    # Below -  Generates the slug for a city field, if city name is already taken, adds county name without "-county", then state abbreviation if taken.
    def slug_candidates
      [
        :name,
        [:name, :id]
      ]
    end 

  # Below - Determines if there's a blank or new Record to assign a slug to.
  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end
  # ACTS AS FOLLOWABLE gem helps user follow the corresponding category
# End - FRIENDLYID: Adding FriendlyID to Cities URL so City Name is URL (/cities/lakewood) instead of ID. 

# Begin - VALIDATIONS: Validations for City Table.
  # Below - Ensures a county is associated with a City.
  validates :county_id, presence: { message: 'A city must have an affiliated county with it.' }, allow_blank: true
  # Below - Ensures a name is included in a City.
  validates :name, presence: { message: 'A city must have a name.' }
  # Below - Ensures uniqueness of latitude and longitude attached to a city with both scoped.
  validates_uniqueness_of :latitude, scope: :longitude
  validates_uniqueness_of :longitude, scope: :latitude
  # Below - Plain validation of email so that a CAC can be sent to a city.   
  validates :email, presence: { message: 'A city must have an email so when a complaint or petition is filed, a CAC or CAP is sent accordingly. And for admin creation email validation.' }

# End - VALIDATIONS: Validations for City Table.

# Begin - ASSOCIATIONS: Many/Belongs To/One Relations for City table.   
  # Below - Associates a one to many City with a county. (County has_many cities)
  belongs_to :county, optional: true
  # Below - Associates a one to many City with a county. (States has_many cities)
  has_one :state, :through => :county
  # Below - Associates BLANK as a has one to BLANK relationship with BLANK. (BLANK belongs to BLANK)  
  has_one :city_workplace, -> { where(is_citys: true) }, class_name: "Workplace", foreign_key: "city_id"
  # Below - Associates cities as a has one to one relationship with ZipCodes. (Zipcode belongs to Cities)  
  has_one :zip, class_name: "ZipCode", foreign_key: "city_id"
  # Below - Associates City Model with Cityscore Table as a One to One Association (city_score belongs_to City)
  has_one :city_score, class_name: "CityScore", foreign_key: "city_id"
    has_one :government_score, :through => :city_score
    has_one :police_score, :through => :city_score
    has_one :public_score, :through => :city_score
    has_one :park_score, :through => :city_score
    has_one :school_score, :through => :city_score
    has_one :city_review_score, :through => :city_score
    has_one :complaint_score, :through => :city_score
    has_one :petition_score, :through => :city_score
  # Below - Associates City Model with Department Review as a Many to One Association (DepartmentReview Belongs_to City)
  has_many :department_reviews, class_name: "DepartmentReview", foreign_key: "city_id"
  # Below - Associates City Model with Users as a Many to One Association (Users Belongs_to City)
  has_many :users, class_name: "User", foreign_key: "city_id"
  # Below - Associates a many to one association with City to Admin. (Admin belongs to City)
  has_many :admins
  # Below - Associates BLANK as a has many to BLANK relationship with BLANK. (BLANK has BLANK)  
  has_many :super_admins, -> { where(super_admin: true) }, class_name: "Admin", foreign_key: "city_id"
  # Below - Associates City Model with Complaint Table as a Many to one Association (Complaint belongs_to City)
  has_many :complaints, class_name: "Complaint", foreign_key: "city_id"
  # Below - Associates City Model with Department table as a Many to one Association (Department belongs_to City)
  #has_many :departments, class_name: "Department", foreign_key: "city_id"
  # Below - Associates City with CityReviews, by City having many City Reviews (CityReviews belongs_to City)
  has_many :city_reviews, class_name: "CityReview", foreign_key: "city_id"
  # Below - Associates City with Topics, by city having many Topics (topics belongs_to City)
  has_many :topics, class_name: "Topic", foreign_key: "city_id"
  # Below - Associates City with Subtopics, by city having many Subtopics (Subtopics belongs_to City)
  has_many :subtopics, class_name: "Subtopic", foreign_key: "city_id"
  # Below - Associates Cities with posts (posts belongs_to city.)
  has_many :posts, class_name: "Post", foreign_key: "city_id"
  # Below - Associates cities with activities so @city.activities can be called on actions like initial posts, complaints, WUL reviews.
  has_many :activities, class_name: "PublicActivity::Activity", foreign_key: "recipient_id"
  # Below - Associates Cities as a has many to one relationship with Petitions. (Petitions belong to :city)  
  has_many :petitions, class_name: "Petition", foreign_key: "city_id"
  # Below - Creates a method call for pending petitions that need signatures to be filed.
  has_many :pending_petitions, -> { where(pending: true) }, class_name: "Petition", foreign_key: "city_id"
  # Below - Creates a method call for filed petitions that have acheived the required goal of signatures (upvotes).
  has_many :filed_petitions, -> { where(filed: true) }, class_name: "Petition", foreign_key: "city_id"
  # Below - Creates a method call for completed petitions that have been enacted.
  has_many :completed_petitions, -> { where(completed: true) }, class_name: "Petition", foreign_key: "city_id"
  # Below - Creates a method call for completed petitions that have been enacted.
  has_many :concerns, class_name: "Concern", foreign_key: "city_id"
  # Below - Associates cities as a has many relationship with zipcodes. This allows cities with more than one zipcode. (ZipCode belongs to city)  
  has_many :zip_codes, class_name: "ZipCode", foreign_key: "city_id"
  # Below - Associates cities as a has many to one relationship with workplaces. (Workplaces belongs to city)  
  has_many :workplaces
  # Below - Associates cities as a has many relationship with Workplace_posts, going through the workplaces table which holds the city_id. (workplace posts belongs to city through workplaces)
  has_many :workplace_posts, through: :workplaces
  
# End - ASSOCIATIONS: Many/Belongs To/One Relations for City table.   

# Begin -  CUSTOM METHODS

  # Below - Splits the city email that the admin is affiliated with into a string from @ on to check email validity for admin creation vrs email domain.  
  def split_email_domain
    return self.email.split('@')[1]
  end   
  
  # Below -Creates a quick method call to see a city's current score  
  def score 
    self.city_score.score
  end   
  # Below -  Counts up all the score factors for a City
  def score_factor_count
    com_count           = self.complaints.finished.count
    dep_review_count    = count_scorable_department_reviews
    city_review_count   = count_scorable_city_reviews
    petition_count      = self.petitions.finished.count
    return score_count  = com_count + dep_review_count + city_review_count + petition_count
  end   
  

  # Below - Rturns the zipcode or zipcodes associated with a city. If a city has more than one zipcode, it returns a array of numbers. 
  def zip_code
    zip_codes = self.zip_codes.pluck(:zip)
    if self.zip_codes.count == 1 
      return self.zip.zip
    else 
      return zip_codes.to_s
    end 
  end 

 # Below -  Returns the city's state's name in one method call of @city.state_name
  def state_name
    self.state.name 
  end   
  
  # Below -  Counts scorable reviews to display in City Score box in AP score factors
  def count_scorable_department_reviews  
    # Below - Collects all the scorable reviews to count for the city
    department_reviews = self.department_reviews.select do |review| 
      review.is_scorable_review? == true
    end 
    return department_reviews.count
  end   
  
  # Below -  Counts scorable reviews to display in City Score box in AP score factors
  def count_scorable_city_reviews  
    # Below - Collects all the scorable reviews to count for the city
    city_reviews = self.city_reviews.select do |review| 
      review.is_scorable_review? == true
    end 
    return city_reviews.count
  end   
  
  # Below - Checks if city has an admin or not  
  def has_admins?
    if self.admins.empty?
      return false
    else 
      return true
    end 
  end   
  
  # Below -  Checks to see if City Workplace exists.
  def has_city_workplace? 
    if self.city_workplace.nil? # City doesn't have a city workplace
      return false 
    else 
      return true
    end
  end   
  
  # Below - Returns the citie's email domain for email calidation. 
  def return_email_domain 
    return "@" + self.email.split('@')[1]
  end   
  # Below -  Creates a new Workplace for a city when one is created. Can also be called from admin registration create if city workplace doesn't exist.
  def setup_city_workplace(admin)
    city = admin.city
    new_city_workplace = city.workplaces.create(name: "#{self.name} Workplace", description: "Main workplace for the City of #{self.name}. This private workplace is automatically provided for #{self.name} and for city officials to collaborate within it.", is_citys: true)
    puts "New City Workplace was created: #{new_city_workplace.inspect}"
  end 
# End -  CUSTOM METHODS

# Begin - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for City Model.
  # Below - When a new city is created, so is a CityScore row with that city's ID. This triggers a callback inside city_score.rb.
    # Below - When a new city is created, so are its topics and subtopics. 
  after_create_commit :new_city_score, :new_city_topics_and_subtopics
  # Below - Also a Workplace is created for the city's first and official workplace, unless somehow there already is one.
  after_create_commit :new_city_workplace, unless: :has_city_workplace?

  # Below - Creates a new CityScore row with this new City ID inside of it. The creation of a new CityScore row creates corresponding Score tables.
  def new_city_score
    # Below - Creates all values of overall score to 80% values of the factored weight score.
    new_city_score = CityScore.create(city_id: self.id, overall_department_score: 20.0, overall_petition_score: 16.0, overall_complaint_score: 20.0, overall_city_review_score: 24.0 )
    puts "New city score was created: #{new_city_score.inspect}"
  end   
  
  # Below -  Creates a new Workplace for a city when one is created. Can also be called from admin registration create if city workplace doesn't exist.
  def new_city_workplace 
    new_city_workplace = Workplace.create(city_id: self.id, name: "#{self.name} Workplace", description: "Main workplace for the City of #{self.name}. This private workplace is automatically provided for #{self.name} and for city officials to collaborate within it.", is_citys: true)
    puts "New City Workplace was created: #{new_city_workplace.inspect}"
  end   
  
  # Below - Creates the default topics for a new city. When the topics are created, then the subtopics creation will ensue.
  def new_city_topics_and_subtopics
    new_city = self
    if new_city.topics.count >= 3 # Topics already exist, so they aren't created again.
      puts "#{new_city.name} City topics already exist."
    else # Topics don't exist, so new topics are created, passing in the newly created topics to subtopic.rb model to seed subtopics.
      lets_talk = new_city.topics.create(name: "Let's Talk", description: "Post anything that's about improving your city and achieving positive progress within it.", slug: "lets-talk")
      good_vibes = new_city.topics.create(name: "Good Vibes", description: "Post anything that's uplifting, happy, or positive about your city.")
      city_affairs = new_city.topics.create(name: "City Affairs", description: "Post anything that concerns your city's bureaucracy and government: policies, laws, city council & officials, ballots, events, public departments, etc.. City Affairs is the portal for your city's government.")
      puts "#{new_city.name} City created new topics: #{new_city.topics.pluck(:name)}"
      # Begin - Let's Talk Subtopics: Makes sure Let's Talk topic is empty of subtopics, then creates them if so, otherwise returns a statement.
      if lets_talk.subtopics.empty? # Let's talk is empty, so creation of its subtopics occurs
        lets_talk_subtopics = new_city.subtopics.build([
            { name: "Help Me Out",     description: "Post about anything you need help with amongst the boundaries of your city, ranging from accomplishing a common goal to finding your missing dog." },
            { name: "Business Buzz",   description: "Post about your business, local businesses, new businesses, small businesses. Its all of your business!" },
            { name: "Grinds My Gears", description: "Doesn't that just grind your gears? Vent and rant about the things that bug you concerning your city." },
            { name: "Sports",          description: "What's your take on local sports? High school teams, peewee football?" }])
        lets_talk.subtopics << lets_talk_subtopics
        puts "#{new_city.name}'s #{lets_talk.name}'s subtopics created: #{lets_talk.subtopics.pluck(:name)}."
      else # Let's talk already has subtopics.
        puts "There may be an issue with the creation of #{new_city.name}'s topic, #{lets_talk.name}, and its subtopics. #{lets_talk.name} already has these subtopics: #{lets_talk.subtopics.pluck(:name)}."
      end # End - Let's Talk Subtopics
      # Begin - Good Vibes Subtopics: Makes sure Good Vibes topic is empty of subtopics, then creates them if so, otherwise returns a statement.
      if good_vibes.subtopics.empty? # Good Vibes is empty, so creation of its subtopics occurs
        good_vibes_subtopics = new_city.subtopics.build([
            { name: "Good News",       description: "Heard something about your city that just makes you feel good about it? Or something inside your city that uplifts? Spread the good news!",},
            { name: "Furry Friends",   description: "You love your cat or dog. We do, too. Post about the cute creatures of your city." },
            { name: "City Snaps",      description: "Share your favorite picture of your city or anything related to it." },
            { name: "Local Historian", description: "Your city has a lot of history. Share it and interesting stories you find buried in the past!" }])
        good_vibes.subtopics << good_vibes_subtopics
        puts "#{new_city.name}'s #{good_vibes.name}'s subtopics created: #{good_vibes.subtopics.pluck(:name)}."
      else # Good Vibes already has subtopics.
        puts "There may be an issue with the creation of #{new_city.name}'s topic, #{good_vibes.name}, and its subtopics. #{good_vibes.name} already has these subtopics: #{good_vibes.subtopics.pluck(:name)}."
      end # End - GOod Vibes Subtopics:
      # Begin - Good Vibes Subtopics: Makes sure Good Vibes topic is empty of subtopics, then creates them if so, otherwise returns a statement.
      if city_affairs.subtopics.empty? # Good Vibes is empty, so creation of its subtopics occurs
        city_affairs_subtopics = new_city.subtopics.build([
            { name: "Ballots",           description: "Ballots and measures for your local city."},
            { name: "Events",            description: "Events in your city: townhalls, citizen gatherings, protests, zoning, official meetings, and so on." },
            { name: "City Improvements", description: "Post about ways and means to improve you city, ranging from governmental to community reforms." },
            { name: "Schools",           description: "Discuss the happenings within your local school district. Policies, teachers, curriculum, and so on." }])
        city_affairs.subtopics << city_affairs_subtopics
        puts "#{new_city.name}'s #{city_affairs.name}'s subtopics created: #{city_affairs.subtopics.pluck(:name)}."
      else # Good Vibes already has subtopics.
        puts "There may be an issue with the creation of #{new_city.name}'s topic, #{city_affairs.name}, and its subtopics. #{city_affairs.name} already has these subtopics: #{city_affairs.subtopics.pluck(:name)}."
      end # End - GOod Vibes Subtopics:
    end 
  end 
  
# End - CUSTOM CALLBACKS: Before_save, after_commit, & Callbacks for City Model.

end
