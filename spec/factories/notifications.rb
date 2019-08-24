FactoryBot.define do
  factory :notification do
    recipient_id 1
    actor_id 1
    read_at "2018-07-31 15:28:13"
    action "MyString"
    notifiable_id 1
    notifiable_type "MyString"
  end
end
