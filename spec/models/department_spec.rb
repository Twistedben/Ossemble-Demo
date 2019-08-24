# Department spec tests for model 
=begin 
create_table "departments", force: :cascade do |t|
    t.string "name"
    t.float "score", limit: 5
    t.integer "city_score_id"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "city_id"
    t.string "slug"
    t.string "address"
    t.integer "category_id"
    t.string "category_type"
    t.string "images"
    t.index ["city_id"], name: "index_departments_on_city_id"
    t.index ["city_score_id"], name: "index_departments_on_city_score_id"
    t.index ["slug"], name: "index_departments_on_slug"
  end
=end
require 'rails_helper'

RSpec.describe Department, type: :model do
  
  describe '#department - The creation of a new department', type: :department do 
    
    it "checks the existence of a new department's attributes" do 
      city = create(:city)
      department = Department.create(id: 2, name: "Madison Park", address: "4567 Ridge", city_score_id: 1, latitude: 43, longitude: -80, city_id: city.id, category_id: 1, category_type: "ParkScore")
      expect(department.valid?).to be true 
      expect(department.id).to be_truthy
      expect(department.name).to eq 'Madison Park'
      expect(department.address).to eq '4567 Ridge'
      expect(department.city_id).to be_truthy
      expect(department.city_score_id).to be_truthy
      expect(department.category_id).to be_truthy
      expect(department.category_type).to eq("ParkScore")
      expect(department.latitude).to be_truthy
      expect(department.longitude).to be_truthy
    end 
    
    it 'tests the association of a department to city and score tables' do 
      city = create(:city)
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
    
    it 'tests the validations of a new department' do 
      city = create(:city)
      city_2 = create(:city_2)
      department_test = Department.create(name: "City Hall", address: "4562", city_score_id: 1, latitude: 44.356, longitude: -82.456, city_id: city.id, category_id: 1, category_type: "GovernmentScore" )
      department = Department.create(name: "City Hall", address: "4562", city_score_id: 1, latitude: 44.356, longitude: -82.456, city_id: city.id, category_id: 1, category_type: "GovernmentScore" )
      expect(department.valid?).to be false 
      expect(department.errors[:name].any?).to be_truthy 
      puts "#{department.name} failed to be created because another department within that city has the same name. Errors: #{department.errors.details}".green
      department_2 = Department.create(name: "City Hall", address: "4523", city_score_id: 2, latitude: 34.45, longitude: -81.23465, city_id: city_2.id, category_id: 2, category_type: "GovernmentScore")
      expect(department_2.valid?).to be true 
      expect(department_2.errors[:name].any?).to be_falsey
      puts "#{department_2.name} was created despite there being a similarily named department in another city that city has the same name. Errors: #{department_2.errors.details}".green
      department_3 = Department.create(name: "Horace Mann Elementary School", address: "", city_score_id: 1, latitude: 46.56, longitude: -81.456, city_id: city.id, category_id: 1, category_type: "SchoolScore")
      expect(department_3.valid?).to be false 
      expect(department_3.errors[:address].any?).to be_truthy
      puts "#{department_3.name} failed to be created due to a blank and short address. Errors: #{department_3.errors.details}".green
      department_4 = Department.create(name: "Cove Park", address: "5431", latitude: 44.56, longitude: -82.56, city_id: city.id, category_id: 1, category_type: "ParkScore")
      expect(department_4.valid?).to be false 
      expect(department_4.errors[:city_score_id].any?).to be_truthy
      puts "#{department_4.name} failed to be created due to no city score id. Errors: #{department_4.errors.details}".green
      department_5 = Department.create(name: "Madison Park", address: "54431", city_score_id: 1, latitude: 48.556, longitude: -81.556, category_id: 1, category_type: "ParkScore")
      expect(department_5.valid?).to be false 
      expect(department_5.errors[:city_id].any?).to be_truthy
      puts "#{department_5.name} failed to be created due to no city id. Errors: #{department_5.errors.details}".green
      department_6 = Department.create(name: "Celeste Park", address: "57431", city_score_id: 1, latitude: 44.5896, longitude: -80.5546, city_id: city.id, category_type: "ParkScore")
      expect(department_6.valid?).to be false 
      expect(department_6.errors[:category_id].any?).to be_truthy
      puts "#{department_6.name} failed to be created due to no category id. Errors: #{department_6.errors.details}".green
      department_7 = Department.create(name: "High School", address: "55731", city_score_id: 1, latitude: 44.5586, longitude: -80.6556, city_id: city.id, category_id: 1)
      expect(department_7.valid?).to be false 
      expect(department_7.errors[:category_type].any?).to be_truthy
      puts "#{department_7.name} failed to be created due to no category type. Errors: #{department_7.errors.details}".green
      department_8 = Department.create(name: "Middle School", address: "5231", city_score_id: 1, longitude: -80.5356, city_id: city.id, category_id: 1, category_type: "SchoolScore")
      expect(department_8.valid?).to be false 
      expect(department_8.errors[:latitude].any?).to be_truthy
      puts "#{department_8.name} failed to be created due to no latitude value. Errors: #{department_8.errors.details}".green
      department_9 = Department.create(name: "Elementary School", address: "7831", city_score_id: 1, latitude: 50.5356, city_id: city.id, category_id: 1, category_type: "SchoolScore")
      expect(department_9.valid?).to be false 
      expect(department_9.errors[:longitude].any?).to be_truthy
      puts "#{department_9.name} failed to be created due to no longitude value. Errors: #{department_9.errors.details}".green
      department_10 = Department.create(name: "City Hall School", address: "7831", city_score_id: 1, latitude: 34.45, longitude: -81.23465, city_id: city.id, category_id: 1, category_type: "SchoolScore")
      expect(department_10.valid?).to be false 
      expect(department_10.errors[:latitude].any?).to be_truthy
      puts "#{department_10.name} failed to be created due to having the same latitude and longitude value of City Hall. Errors: #{department_10.errors.details}".green
      
    end
    
    it 'user, city, department, and review is properly associated' do 
      city = create(:city)
      city_2 = create(:city_2)
      user = create(:user)
      department = create(:department, city_id: city.id)
      review = create(:review, user_id: user.id)
      city.departments << department 
      department.reviews << review
      city_departments = city.departments 
      department_reviews = department.reviews
      expect(city_departments).to be_truthy
      expect(department_reviews).to be_truthy 
    end  
    
  end 
  
  
end
