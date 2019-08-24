# == Schema Info 
# Departments
=begin 
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
=end 
FactoryBot.define do
  factory :department, class: Department do
   id 1
   name "City Hall"
   score 80.00
   city_score_id 1
   latitude 41.484982
   longitude -81.777036 
   city_id 1
   address "12650 Detroit Avenue"
   category_id 1 
   category_type "GovernmentScore"
  end  
  factory :department_2, class: Department do
   id 2
   name "North Royalton High School"
   score 80.00
   city_score_id 2
   latitude 42.484982
   longitude -81.7036
   city_id 2
   address "7877 Detroit Avenue"
   category_id 2 
   category_type "SchoolScore"
  end
  factory :department_gov, class: Department do
   id 3
   name "City Hall"
   score 80.00
   city_score_id 1
   latitude 40.87982
   longitude -81.732036 
   city_id 1
   address "12650 Detroit Avenue"
   category_id 1 
   category_type "GovernmentScore"
  end  
  factory :department_school, class: Department do
   id 4
   name "Horace Mann Elementary School"
   score 80.00
   city_score_id 1
   latitude 43.3982
   longitude -81.6036
   city_id 1
   address "1215 West Clifton Boulevard"
   category_id 1
   category_type "SchoolScore"
  end
  factory :department_park, class: Department do
   id 5
   name "Cove Park"
   score 80.00
   city_score_id 1
   latitude 45.5643982
   longitude -81.376036
   city_id 1
   address "1215 West Clifton Boulevard"
   category_id 1
   category_type "ParkScore"
  end
  # Below - Review factories for departments
  factory :review, class: Review do 
    id 1 
    description "This is a good test review of this department with a score of 80% and minimum character length of 150! There is really friendly people there and helpful!!!!!!!!!!"
    score 80
    department_id 1
    user_id 1
  end 
  factory :review_gov_50, class: Review do 
    id 2 
    description "This is a bad, low test review of this department with a score of 50% and minimum character length of 150! The people are NOT friendly and not helpful at all!"
    score 50
    department_id 3
    user_id 1
  end 
  factory :review_gov_90, class: Review do 
    id 3
    description "This is a good, high test review of this department with a score of 90% and minimum character length of 150! The people are NOT friendly and not helpful at all!"
    score 90
    department_id 3
    user_id 2
  end 
  factory :review_school_50, class: Review do 
    id 4
    description "This is a bad, low test review of this department with a score of 50% and minimum character length of 150! The people are NOT friendly and not helpful at all!"
    score 50
    department_id 4
    user_id 1
  end 
  factory :review_school_90, class: Review do 
    id 5
    description "This is a good, high test review of this department with a score of 90% and minimum character length of 150! The people are NOT friendly and not helpful at all!"
    score 90
    department_id 4
    user_id 2
  end 
  factory :review_park_50, class: Review do 
    id 6
    description "This is a bad, low test review of this department with a score of 50% and minimum character length of 150! The people are NOT friendly and not helpful at all!"
    score 50
    department_id 5
    user_id 1
  end 
  factory :review_park_90, class: Review do 
    id 7
    description "This is a good, high test review of this department with a score of 90% and minimum character length of 150! The people are NOT friendly and not helpful at all!"
    score 90
    department_id 5
    user_id 2
  end 
  
end