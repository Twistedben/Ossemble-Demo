# == Schema Info 
# City Reviews
=begin 
    t.string "title"
    t.text "description", null: false
    t.integer "score", null: false
    t.integer "city_id", null: false
    t.integer "user_id", null: false
    t.integer "city_review_score_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["city_id"], name: "index_city_reviews_on_city_id"
    t.index ["city_review_score_id"], name: "index_city_reviews_on_city_review_score_id"
    t.index ["slug"], name: "index_city_reviews_on_slug"
    t.index ["user_id"], name: "index_city_reviews_on_user_id"
# City Review Score
    t.float "score", limit: 5, default: 80.0, null: false
    t.integer "city_id", null: false
    t.integer "city_score_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_city_review_scores_on_city_id"
    t.index ["city_score_id"], name: "index_city_review_scores_on_city_score_id"
=end 
FactoryBot.define do
  factory :city_review, class: CityReview do 
    id 1
    title "What I Love About Lakewood"
    description "Lakewood s truly a great city. It has recreating abilities like how! Amazing waterfront, yoga, lots of hipsters and diverse people, that's just fantastic."
    score 80
    love_list "Parks, Buses, Roads"
    improve_list "Police, Biking, Bars"
    city_id 1 
    user_id 1
    city_review_score_id 1 
  end 
  
  factory :city_review_score, class: CityReviewScore do 
    id 1 
    score 80.0
    city_id 1
    city_score_id 1 
  end
  
end