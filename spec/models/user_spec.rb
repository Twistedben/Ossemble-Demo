# == Schema Information
#
# Table name: users
=begin
t.string "first_name", null: false
    t.string "last_name"
    t.boolean "admin", default: false
    t.boolean "subscribed", default: true
    t.string "zip", default: "44107", null: false
    t.string "phone_number"
    t.string "address"
    t.string "state", default: "Ohio", null: false
    t.date "dob"
    t.integer "city_id", default: 1
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address2"
    t.string "gender"
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "avatar"
    t.text "bio", limit: 200
    t.string "slug"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
#
=end
require 'rails_helper'

RSpec.describe User, type: :model do
  
  describe User, "#user - The creation of a new user", type: :user do 
    before (:each) do 
      @city = create(:city)
      @user = create(:user)
    end 
    
    it 'checks existence of a new user' do 
      expect(@user.valid?).to be true
      expect(@user.city).to eq(City.first)
      expect(@user.id).to be_truthy
      expect(@user.first_name).to eq('Benjamin')
      expect(@user.last_name).to eq('Broestl')
      expect(@user.address).to eq('15951 Ridge Road')
      expect(@user.gender).to eq('Male')
      expect(@user.email).to eq('benjaminb@example.com')
      expect(@user.zip).to eq(@user.city.zip)
      expect(@user.state).to eq(@user.city.state)
      expect(@user.name).to eq('Benjamin Broestl') # Tests model callback for created full name, :name attribute.
    end 
    
    it 'tests the validations of a new user' do 
      user_1 = User.create(id: 5, first_name: "Billy", last_name: "Bob", zip: "44107", address: "4536 Main", state: "Ohio", city_id: 1, gender: "Male", dob: "1980-04-12", email: "Billyb@example.com", password: "password", confirmed_at: Time.now)
      user_2 = User.create(id: 6, first_name: "Billy", last_name: "Bob", zip: "44107", address: "4536 Main", state: "Ohio", city_id: 1, gender: "Male", dob: "1980-04-12", email: "Billyb@example.com", password: "password", confirmed_at: Time.now)
      user_3 = User.create(id: 7, first_name: "Jim", last_name: "Page", zip: "", address: "3596 Main", state: "Ohio", city_id: 1, gender: "Male", dob: "1999-04-04", email: "Jimp@example.com", password: "password", confirmed_at: Time.now)
      user_4 = User.create(id: 8, first_name: "John", last_name: "Lennon", zip: "44107", address: "3466 Main", state: "Ohio", city_id: 1, gender: "", dob: "1999-04-04", email: "Johnl@example.com", password: "password", confirmed_at: Time.now)
      user_5 = User.create(id: 9, first_name: "Bruce", last_name: "Willis", zip: "44107", address: "", state: "Ohio", city_id: 1, gender: "Male", dob: "1999-04-04", email: "Brucew@example.com", password: "password")
      user_6 = User.create(id: 10, first_name: "Bill", last_name: "Murray", zip: "44107", address: "54843 Main", state: "Ohio", city_id: 1, gender: "Male", dob: "1999-04-04", email: "sfagafdg.com", password: "password")
      user_7 = User.create(id: 11, first_name: "Ringo", last_name: "Star", zip: "44107", address: "54673 Main", state: "Ohio", city_id: 1, gender: "Male", dob: "", email: "Ringos@example.com", password: "password")
      user_8 = User.create(id: 12, first_name: "Paul", last_name: "McCartny", zip: "44107", address: "67673 Main", state: "Ohio", city_id: 1, gender: "Male", dob: "1856-05-09", email: "", password: "password")
      expect(user_2.valid?).to be false
      expect(user_2.errors[:email].any?).to be_truthy 
      puts "#{user_1.name} failed to be created because another user has the same email already. User 1 Email: #{user_1.email}, User 2 email #{user_2.email}. Errors: #{user_2.errors.details}".green
      expect(user_3.valid?).to be false 
      expect(user_3.errors[:zip].any?).to be_truthy 
      puts "#{user_3.first_name} failed to be created because no zip code. Errors: #{user_3.errors.details}".green
      expect(user_4.valid?).to be false 
      expect(user_4.errors[:gender].any?).to be_truthy 
      puts "#{user_4.first_name} failed to be created because gender was not selected. Errors: #{user_4.errors.details}".green
      expect(user_5.valid?).to be false 
      expect(user_5.errors[:address].any?).to be_truthy 
      puts "#{user_5.first_name} failed to be created because address was not inputted. Errors: #{user_5.errors.details}".green
      expect(user_6.valid?).to be false 
      expect(user_6.errors[:email].any?).to be_truthy 
      puts "#{user_6.first_name} failed to be created because email address is a bad format. Errors: #{user_6.errors.details}".green
      expect(user_7.valid?).to be false 
      expect(user_7.errors[:dob].any?).to be_truthy 
      puts "#{user_7.first_name} failed to be created because date of birth was not inputted. Errors: #{user_7.errors.details}".green
      expect(user_8.valid?).to be false 
      expect(user_8.errors[:email].any?).to be_truthy 
      puts "#{user_8.first_name} failed to be created because email was not inputted. Errors: #{user_8.errors.details}".green
    end 
    
  end # End of new user describe block.
  
  describe City, '#city - user interactions with a city ', type: :user do 
    
    it 'user is properly associated within a city' do 
      city = create(:city)
      user = create(:user, city_id: city.id, zip: city.zip)
      city_users = city.users
      
      expect(city_users.size).to eq(1)
      expect(city_users).to_not be_empty
      expect(city_users).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(city_users).to include(user)
    end 
    
    it 'user in another city appears only there' do 
      city = create(:city)
      city_2 = create(:city_2)
      user = create(:user, city_id: city.id, zip: city.zip)
      create(:user_2, city_id: city_2.id, zip: city_2.zip)
      create(:user_3, city_id: city_2.id, zip: city_2.zip)
      city_users = city.users
      city_2_users = city_2.users
      
      expect(city_2_users).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(city_2_users).to_not include(user)
      expect(city_users.size).to eq(1)
      expect(city_2_users.size).to eq(2)
    end 
    
  end # End - User interation with a city describe block
  
  describe Complaint, '#complaint - user interactions with complaints & comments', type: :user do 
   
    before (:each) do 
      @city = create(:city)
      @user = create(:user)
      @admin = create(:admin_user)
      @complaint_category = create(:complaint_category_1)
      @complaint = create(:complaint_v, user_id: 1, city_id: 1)
      @user.complaints << @complaint
      @user_complaints = @user.complaints
    end 
    
    
    it 'user is properly associated with a complaint' do 
      expect(@user.id).to be_truthy 
      expect(@complaint.id).to be_truthy 
      expect(@user.id).to eq(@complaint.user_id) 
      expect(@user_complaints).to_not be_empty
      expect(@user_complaints).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(@user_complaints).to include(@complaint)
    end # End - User association with a complaint
    
    it 'user can only have one verifying complaint at a time' do 
      complaint_2 = Complaint.create(id: 7, city_id: 1, user_id: 1, latitude: 43.54, longitude: -80.32, verifying: true, complaint_score_id: 1)
      @user.complaints << complaint_2 
      expect(complaint_2.valid?).to be false
      expect(@user.complaints.where(verifying: true).size).to eq(1)
      expect(complaint_2.errors[:user_id].any?).to be_truthy
      puts "User could not create complaint due to having more than one verifying in a day, Errors: #{complaint_2.errors.details}".green
    end 
    
    it 'user and comment is properly associated' do 
      comment = Comment.create(id: 1, description: "This is a test comment on a complaint.", user_id: @user.id, commentable_id: @complaint.id, commentable_type: "Complaint")
      @complaint.comments << comment 
      complaint_comments = @complaint.comments 
      expect(complaint_comments).to_not be_empty 
      expect(complaint_comments).to be_a(ActiveRecord::Associations::CollectionProxy)
      expect(complaint_comments).to include(comment)
    end 
    
  end # End - User interaction with a city describe block
  
  describe Review, '#department - user interactions with departments & reviews', type: :user do 
    
    it 'user and review is properly associated' do 
      city = create(:city)
      user = create(:user)
      department = create(:department, city_id: city.id)
      review = create(:review, user_id: user.id)
      user.reviews << review
      user_reviews = user.reviews
      expect(user_reviews).to be_truthy
      expect(user_reviews).to_not be_empty
      expect(user_reviews).to be_a(ActiveRecord::Associations::CollectionProxy) 
      expect(user_reviews).to include(review)
      expect(user_reviews.count).to eq(1)
    end  
    
    it 'user can review a specific department only once' do 
      city = create(:city)
      user = create(:user)
      department = create(:department, city_id: city.id)
      review = create(:review, user_id: user.id)
      expect(review.valid?).to be true 
      expect(department.reviews).to be_truthy
      expect(department.reviews).to include(review)
      review_2 = Review.create(description: "This is a good, high test review of this department with a score of 90% and minimum character length of 250! The people are NOT friendly and not helpful at all!", user_id: user.id, score: 80, department_id: department.id)
      expect(review_2.valid?).to be false 
      expect(review_2.errors[:user_id].any?).to be_truthy
      expect(department.reviews).to_not include(review_2)
      puts "User could not review because they already reviewed the department, Errors: #{review_2.errors.details}".green
    end 
    
  end # End - User interaction with a Department

  
  
end
