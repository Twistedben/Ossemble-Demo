# == Schema Information
#
# Table name: cities
#
#  id        :integer          not null, primary key
#  name      :string           not null
#  zip       :string           not null
#  county_id :integer
#  state     :string
#    t.string "slug"
#    t.float "latitude"
#    t.float "longitude"
#    t.string "email"

require 'rails_helper'

RSpec.describe City, type: :model do
  
  # OneNote RSPEC Tests: 1. a. i.
  describe City, "#city - The creation of a new city, and its associated score tables", type: :city do 

    it "checks the existence of a new city's attributes"  do
      city = City.create(id: 1, name: "Lakewood", zip: '44107', state: 'Ohio', latitude: 41.482473, longitude: -81.79826)
      expect(city.valid?).to be true
      expect(city.id).to be_truthy
      expect(city.name).to eq 'Lakewood'
      expect(city.zip).to eq '44107'
      expect(city.state).to eq 'Ohio'
      expect(city.latitude).not_to be nil 
      expect(city.longitude).not_to be nil 
      expect(City.count).to eq(1)
    end 
    
    # OneNote RSPEC TEsts: 1. a. i. 1.
    it "tests validations of a new city" do
      city_1 = City.create(id: 1, name: "Lakewood", zip: '44107', state: 'Ohio', latitude: 41.482473, longitude: -81.79826)
      city_2 = City.create(id: 2, name: 'Lakewood', zip: '44107', state: 'Ohio', latitude: 44.66667, longitude: -80.56474)
      city_3 = City.create(id: 3, name: "North Royalton", zip: '44133', state: "Ohio", latitude: 44.236, longitude: -85.879)
      city_4 = City.create(id: 4, name: "Rocky River", zip: '44733', state: "Ohio", latitude: 44.236, longitude: -85.879)
      city_5 = City.create(id: 5, name: "Cleveland", zip: '44536', state: "Ohio", latitude: 44.236, longitude: -82.87469)
      expect(city_2.valid?).to be false
      expect(city_2.errors[:zip].any?).to be_truthy
      puts "#{city_2.name} failed to be created because another city has the same zip. City 1: #{city_1.zip}, City 2: #{city_2.zip}. Errors: #{city_2.errors.details}".green
      expect(city_4.valid?).to be false
      expect(city_4.errors[:latitude].any?).to be_truthy
      puts "#{city_3.name} failed to be created because another city has the same latitude and longitude. City 3 Long: #{city_3.longitude} City 3 Lat: #{city_3.longitude} City 2 Long: #{city_4.longitude} City 2 Lat: #{city_4.latitude} Errors: #{city_4.errors.details}".green
      expect(city_5.valid?).to be true 
      expect(city_5.errors[:latitude].any?).to be_falsey
      expect(city_5.errors[:longitude].any?).to be_falsey
      expect(City.count).to eq(3)
    end 
    
    
    it 'ensures a City Score table is created and associated with the new City' do
      city = City.create(id: 1, name: "Lakewood", zip: '44107', state: 'Ohio', latitude: 41.482473, longitude: -81.79826)
      city_score = city.city_score              # Created in City.rb model callback
      expect(city_score).to be_truthy
      expect(city_score.city_id).to eq(city.id)
    end
 
    it 'ensures a Government Score Table is created and associated with the new city and City Score table, as well as a score available' do 
      city = City.create(id: 1, name: "Lakewood", zip: '44107', state: 'Ohio', latitude: 41.482473, longitude: -81.79826)
      city_score = city.city_score              # Created in City.rb model callback
      government_score = city.government_score  # Created in CityScore.rb model callback
      expect(government_score).to be_truthy
      expect(government_score.score).to be_truthy
      expect(government_score.city_id).to eq(city.id)
      expect(government_score.city_score_id).to eq(city.city_score.id)
    end 
    
    it 'ensures a School Score Table is created and associated with the new city and City Score table, as well as a score available' do 
      city = City.create(id: 1, name: "Lakewood", zip: '44107', state: 'Ohio', latitude: 41.482473, longitude: -81.79826)
      city_score = city.city_score              # Created in City.rb model callback
      school_score = city.school_score          # Created in CityScore.rb model callback
      expect(school_score).to be_truthy
      expect(school_score.score).to be_truthy
      expect(school_score.city_id).to eq(city.id)
      expect(school_score.city_score_id).to eq(city.city_score.id)
    end
  
    it 'ensures a Park Score Table is created and associated with the new city and City Score table, as well as a score available' do 
      city = City.create(id: 1, name: "Lakewood", zip: '44107', state: 'Ohio', latitude: 41.482473, longitude: -81.79826)
      city_score = city.city_score              # Created in City.rb model callback
      park_score = city.park_score              # Created in CityScore.rb model callback
      expect(park_score).to be_truthy
      expect(park_score.score).to be_truthy
      expect(park_score.city_id).to eq(city.id)
      expect(park_score.city_score_id).to eq(city.city_score.id)   
    end
    
    it 'ensures a Complaint Score Table is created and associated with the new city and City Score table, as well as a score available' do 
      city = City.create(id: 1, name: "Lakewood", zip: '44107', state: 'Ohio', latitude: 41.482473, longitude: -81.79826)
      city_score = city.city_score              # Created in City.rb model callback
      complaint_score = city.complaint_score    # Created in CityScore.rb model callback
      expect(complaint_score).to be_truthy
      expect(complaint_score.score).to be_truthy
      expect(complaint_score.city_id).to eq(city.id)
      expect(complaint_score.city_score_id).to eq(city.city_score.id)
    end 
    
    it 'ensures a City Review Score Table is created and associated with the new city and City Score table, as well as a score available' do 
      city = City.create(id: 1, name: "Lakewood", zip: '44107', state: 'Ohio', latitude: 41.482473, longitude: -81.79826)
      city_score = city.city_score              # Created in City.rb model callback
      city_review_score = city.city_review_score    # Created in CityScore.rb model callback
      expect(city_review_score).to be_truthy
      expect(city_review_score.score).to be_truthy
      expect(city_review_score.city_id).to eq(city.id)
      expect(city_review_score.city_score_id).to eq(city.city_score.id)
    end 
    
  end # ENd of Describe City with creation of it and its associated Score Tables
  
  # OneNote RSPEC Tests: 1. a. ii.
  describe User, "The creation of a new #city and an associated #user for that city", type: :city do 
    
    it '#user - Ensures a new user is properly associated with the City table' do
      city = create(:city_2)
      user = create(:user, city_id: city.id, zip: city.zip)
      city.users << user
      city_users = city.users
      expect(city.id).to be_truthy
      expect(user.id).to be_truthy
      expect(user.state).to eq(city.state)
      expect(user.zip).to eq(city.zip)
      expect(city_users).to_not be_empty
      expect(city_users).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(city_users).to include(user)
      expect(city_users.first.city_id).to eq(city.id)
    end
  end   # End of describe User for user creation within a city
  
  # OneNote RSPEC Tests: 1. a. iii.
  describe Complaint, "#complaint - the creation of a new #city and an associated #complaint for that city", type: :city do 
    
    it 'city is properly associated with a complaint' do
      city = create(:city)
      user = create(:user)
      complaint = Complaint.create(id: 1, address: "Near post office", description: "There is a huge pothole outside of the post office.", user_id: user.id, city_id: city.id, complaint_category_id: 1, longitude: 43.3455, latitude: -84.3453)
      city.users << user
      city.complaints << complaint
      city_complaints = city.complaints
      expect(city.id).to be_truthy
      expect(complaint.id).to be_truthy
      expect(city_complaints.first.city_id).to eq(city.id)
      expect(city_complaints).to_not be_empty
      expect(city_complaints).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(city_complaints).to include(complaint)
    end
  
  end # End of Describe Complaint for Complaint creation within a city
  
  # OneNote RSPEC Tests: 1. a. iv.
  describe CityReview, "The creation of a new #city and an associated #city_review for that city", type: :city do 
    
    it '#city_review - Ensures a new City Review is properly associated with the City table' do
      city = create(:city)
      user = create(:user)
      city_review = create(:city_review, city_id: city.id, user_id: user.id)
      city.city_reviews << city_review
      city_reviews = city.city_reviews
      expect(city.id).to be_truthy
      expect(city_review.id).to be_truthy
      expect(city_reviews.first.city_id).to eq(city.id)
      expect(city_reviews).to_not be_empty
      expect(city_reviews).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(city_reviews).to include(city_review)
    end
  
  end # End of Describe City Review for City Review creation within a city
  # OneNote RSPEC Tests: 1. a. iv.
  describe Department, "The creation of a new #city and an associated #department for that city", type: :city do 
    
    it '#department - Ensures a new department is properly associated with the City table' do
      city = create(:city_4)
      department = create(:department, city_id: city.id)
      city.departments << department
      city_departments = city.departments
      expect(city.id).to be_truthy
      expect(department.id).to be_truthy
      expect(city_departments.first.city_id).to eq(city.id)
      expect(city_departments).to_not be_empty
      expect(city_departments).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(city_departments).to include(department)
    end
  
  end # End of Describe Department for Department creation within a city

  
end
