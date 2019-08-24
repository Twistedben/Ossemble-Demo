FactoryBot.define do
  factory :department_review do
    score 1
    title "MyString"
    description "MyText"
    user_id 1
    city_id 1
    scorable_id 1
    scorable_type "MyString"
    slug "MyString"
  end
end
