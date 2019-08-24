require 'rails_helper'

RSpec.describe CityReview, type: :model do

  describe CityReview, "#city_review - The creation of a new city_review", type: :city_review do 

    it "checks the existence of a new city review's attributes"  do
      city = create(:city)
      user = create(:user)
      city_review = create(:city_review)
      expect(city_review.valid?).to be true
      expect(city_review.id).to be_truthy
      expect(city_review.title).to eq 'What I Love About Lakewood'
      expect(city_review.description).to be_truthy
      expect(city_review.score).to eq (80)
      expect(city_review.love_list).to include "Parks", "Buses", "Roads"
      expect(city_review.improve_list).to include "Police", "Biking", "Bars"
      expect(city_review.city_id).not_to be nil 
      expect(city_review.user_id).not_to be nil 
      expect(city_review.city_review_score_id).to eq(1)
    end 
    
    it "tests validations of a new city review" do
      city = create(:city)
      user = create(:user)
      city_review = create(:city_review) 
      expect(city_review.valid?).to be true
      expect(city_review.errors).to be_empty
      city_review_2 = CityReview.create(:city_review, user_id: user.id)
      expect(city_review_2.valid?).to be false
      expect(city_review_2.errors[:user_id].any?).to be_truthy
      puts "#{city_review_2.title} failed to be created because another review has the same user. Errors: #{city_2.errors.details}".green
     # expect(city_4.valid?).to be false
#expect(city_4.errors[:latitude].any?).to be_truthy
     # puts "#{city_3.name} failed to be created because another city has the same latitude and longitude. City 3 Long: #{city_3.longitude} City 3 Lat: #{city_3.longitude} City 2 Long: #{city_4.longitude} City 2 Lat: #{city_4.latitude} Errors: #{city_4.errors.details}".green
     # expect(city_5.valid?).to be true 
#expect(city_5.errors[:latitude].any?).to be_falsey
     # expect(city_5.errors[:longitude].any?).to be_falsey
     # expect(City.count).to eq(3)
    end 
    
    it 'tests the association of a City Review to city and score tables' do 
      city = create(:city)
      user = create(:user)
      city_review = create(:city_review) 
      department = Department.create(id: 2, name: "Madison Park", address: "4567 Ridge", city_score_id: 1, latitude: 43, longitude: -80, city_id: city.id, category_id: 1, category_type: "ParkScore")
      expect(department.city.zip).to eq '44107'
      expect(department.city.state).to eq 'Ohio'
      expect(department.city_score_id).to eq(city.id)
      expect(department.category_id).to eq(city.id)
      expect(department.category_id).to eq(department.category.id)
      expect(department.city_score_id).to eq(department.category.city_score_id)
      expect(department.city_id).to eq(department.category.city_score_id)
      expect(department.latitude).to_not be_falsey
      expect(department.longitude).to_not be_falsey
      expect(city.departments).to_not be_empty
      expect(city.departments).to include(department)
    end 
    
    it 'ensures a department in another city appears only there' do 
      city = create(:city)
      city_2 = create(:city_2)
      department = create(:department)
      department_2 = create(:department_2)
      city.departments << department
      city_2.departments << department_2
      city_departments = city.departments
      city_2_departments = city_2.departments
      expect(city_departments.count).to eq(1)
      expect(city_departments).to include(department)
      expect(city_departments).to_not include(department_2)
      expect(city_2_departments.count).to eq(1)
      expect(city_2_departments).to include(department_2)
      expect(city_2_departments).to_not include(department)
    end 
  end
end
