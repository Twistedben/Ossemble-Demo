# == Schema Info 
# Complaints
=begin 
    t.string "address"
    t.text "description"
    t.integer "user_id"
    t.integer "city_id"
    t.integer "complaint_category_id"
    t.float "longitude"
    t.float "latitude"
    t.integer "score", default: 80
    t.boolean "filed", default: false
    t.boolean "pending", default: false
    t.boolean "verifying", default: true
    t.boolean "completed", default: false
    t.integer "days_left"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "complaint_score_id"
    t.string "images"
    t.boolean "replied", default: false
    t.boolean "planned", default: false
    t.integer "stage", default: 0
    t.datetime "filed_at"
    t.datetime "verified_at"
    t.datetime "completed_at"
    t.integer "cached_votes_total", default: 0
    t.integer "cached_votes_score", default: 0
    t.integer "cached_votes_up", default: 0
    t.integer "cached_votes_down", default: 0
    t.integer "cached_weighted_score", default: 0
    t.integer "cached_weighted_total", default: 0
    t.float "cached_weighted_average", default: 0.0
    t.datetime "planned_at"
    t.datetime "replied_at"
    t.float "vote_threshold", default: 0.0
    t.integer "verified_by_user_id"
    t.boolean "failed", default: false
    t.datetime "failed_at"
    t.string "title"
    t.string "slug"
    t.index ["cached_votes_down"], name: "index_complaints_on_cached_votes_down"
    t.index ["cached_votes_score"], name: "index_complaints_on_cached_votes_score"
    t.index ["cached_votes_total"], name: "index_complaints_on_cached_votes_total"
    t.index ["cached_votes_up"], name: "index_complaints_on_cached_votes_up"
    t.index ["cached_weighted_average"], name: "index_complaints_on_cached_weighted_average"
    t.index ["cached_weighted_score"], name: "index_complaints_on_cached_weighted_score"
    t.index ["cached_weighted_total"], name: "index_complaints_on_cached_weighted_total"
    t.index ["city_id"], name: "index_complaints_on_city_id"
    t.index ["complaint_category_id"], name: "index_complaints_on_complaint_category_id"
    t.index ["completed_at"], name: "index_complaints_on_completed_at"
    t.index ["failed_at"], name: "index_complaints_on_failed_at"
    t.index ["filed_at"], name: "index_complaints_on_filed_at"
    t.index ["latitude"], name: "index_complaints_on_latitude"
    t.index ["longitude"], name: "index_complaints_on_longitude"
    t.index ["planned_at"], name: "index_complaints_on_planned_at"
    t.index ["replied_at"], name: "index_complaints_on_replied_at"
    t.index ["slug"], name: "index_complaints_on_slug"
    t.index ["title"], name: "index_complaints_on_title"
    t.index ["user_id"], name: "index_complaints_on_user_id"
    t.index ["verified_at"], name: "index_complaints_on_verified_at"
    t.index ["verified_by_user_id"], name: "index_complaints_on_verified_by_user_id"
    t.index ["vote_threshold"], name: "index_complaints_on_vote_threshold"
# Complaint Category 
    t.string "category"
    t.integer "deadline"
# Comments 
    t.string "title", limit: 100
    t.text "description"
    t.integer "user_id"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commentable_type"], name: "index_comments_on_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
=end 
FactoryBot.define do
  # Begin - Comment factories which attach to Complaints 
  factory :comment, class: Comment do 
    description "This is a test comment"
    user_id 1
    commentable_id 1 
    commentable_type "Complaint"
  end 
  # End - Comment factories which attach to Complaints 
  # Begin - Complaint Category Factories which Complaints depend on.
  factory :complaint_category_1, class: ComplaintCategory do 
    id 1 
    category "Pothole"
    deadline 21
  end 
  factory :complaint_category_2, class: ComplaintCategory do 
    id 2
    category "Trash"
    deadline 42
  end 
  factory :complaint_category_3, class: ComplaintCategory do 
    id 3
    category "Graffiti"
    deadline 90
  end 
  factory :complaint_category_4, class: ComplaintCategory do 
    id 4
    category "Water"
    deadline 180
  end 
  # End - Complaint Category factories which Complaints depend on.
  
  # Begin - Complaint Factories
  factory :complaint_v, class: Complaint do
    id 1
    address "Near the Post Office"
    description "There is a very big pothole near the post office off the main road."
    user_id 1
    city_id 1
    complaint_category_id 1
    latitude 41.485305613431294
    longitude -81.81524991989137
    score 80
    verifying true
    pending false 
    filed false
    completed false 
    failed false 
    days_left 21
    complaint_score_id 1
    replied false 
    planned false
    replied_at nil
    planned_at nil
    verified_at nil
    verified_by_user_id nil
    filed_at nil 
    completed_at nil 
    failed_at nil
    vote_threshold 0.0
    cached_votes_up 0
    stage 0
    title "Pothole"
    
    factory :complaint_v_p, class: Complaint do 
      verifying false
      pending true       
      verified_at Time.now
      vote_threshold 20.0
      cached_votes_up 2
      verified_by_user_id 2
      
      factory :complaint_v_f, class: Complaint do 
        pending false
        filed true
        filed_at Time.now
        stage 1
        
        factory :complaint_v_stage_2, class: Complaint do 
          days_left 13
          stage 2
          score 60
        end 
        factory :complaint_v_stage_3, class: Complaint do 
          days_left 6
          stage 3
          score 40
        end 
        factory :complaint_v_replied, class: Complaint do 
          replied true 
          replied_at Time.now 
          score 85
        end 
        factory :complaint_v_planned, class: Complaint do 
          planned true 
          planned_at Time.now 
          score 95
        end 
        factory :complaint_v_replied_planned, class: Complaint do 
          planned true 
          planned_at Time.now 
          replied true
          replied_at Time.now
          score 100
        end 
        factory :complaint_v_c, class: Complaint do 
          days_left 0
          filed false
          completed true 
          completed_at Time.now 
          stage 4
        end 
        factory :complaint_v_failed, class: Complaint do 
          days_left 0
          filed false
          failed true 
          failed_at Time.now 
          stage 4
        end 
      end 
    end     
  end  
 
  factory :complaint_p, class: Complaint  do
    id 2
    address "Outside of City Hall"
    description "There is Graffiti all over the side walls of the road outside of City Hall Building."
    user_id 1
    city_id 1
    complaint_category_id 2
    latitude 42.430594
    longitude -81.567699
    score 80
    verifying false
    pending true 
    filed false
    completed false 
    failed false 
    days_left 42
    complaint_score_id 1
    replied false 
    planned false
    replied_at nil
    planned_at nil
    verified_at Time.now
    verified_by_user_id 2
    filed_at nil
    completed_at nil 
    failed_at nil
    vote_threshold 0.0
    cached_votes_up 0
    stage 1
    title "Trash"
  end  
  factory :complaint_f, class: Complaint  do
    id 3
    address "Outside of City Hall"
    description "There is Graffitti all over the side walls of the road outside of City Hall Building."
    user_id 1
    city_id 1
    complaint_category_id 3
    latitude 42.4330594
    longitude -81.5675699
    score 80
    verifying false
    pending false 
    filed true
    completed false 
    failed false 
    days_left 90
    complaint_score_id 1
    replied false 
    planned false
    replied_at nil
    planned_at nil
    verified_at Time.now
    verified_by_user_id 2
    filed_at Time.now 
    completed_at nil 
    failed_at nil
    vote_threshold 20.0
    cached_votes_up 2
    stage 1
    title "Graffiti"
  end  
  factory :complaint_c, class: Complaint  do
    id 4
    address "On the bike path"
    description "There is a huge telephone pole on the bike path, blocking access."
    user_id 1
    city_id 1
    complaint_category_id 4
    latitude 41.5370594
    longitude -81.3565689
    score 80
    verifying false
    pending false 
    filed false
    completed true 
    failed false 
    days_left 0
    complaint_score_id 1
    replied false 
    planned false
    replied_at nil
    planned_at nil
    verified_at Time.now
    verified_by_user_id 2
    filed_at Time.now 
    completed_at Time.now 
    failed_at nil
    vote_threshold 20.0
    cached_votes_up 2
    stage 4
    title "Water"
  end   
  factory :complaint_failed, class: Complaint  do
    id 5
    address "It's near the cove park"
    description "The park is a mess everything is every where every which way."
    user_id 1
    city_id 1
    complaint_category_id 3
    latitude 41.2355643
    longitude -81.7686259
    score 40
    verifying false
    pending false 
    filed false
    completed false 
    failed true 
    days_left 0
    complaint_score_id 1
    replied false 
    planned false
    replied_at nil
    planned_at nil
    verified_at Time.now
    verified_by_user_id 2
    filed_at Time.now 
    completed_at nil
    failed_at Time.now
    vote_threshold 20.0
    cached_votes_up 2
    stage 4
    title "Graffiti"
  end 
  # End - Complaint Factories
end