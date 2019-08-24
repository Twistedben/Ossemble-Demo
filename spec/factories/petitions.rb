FactoryBot.define do
  factory :petition do
    title "MyString"
    goal "MyString"
    description "MyText"
    city_id 1
    user_id 1
    completed false
    completed_at "2018-07-24 00:32:03"
    filed false
    filed_at "2018-07-24 00:32:03"
    replied false
    replied_at "2018-07-24 00:32:03"
    planned false
    planned_at "2018-07-24 00:32:03"
    slug "MyString"
  end
end
