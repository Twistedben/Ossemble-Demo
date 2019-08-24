FactoryBot.define do
  factory :payment_method do
    cb_customer_id "MyString"
    auto_collection false
    payment_type "MyString"
    reference_id "MyString"
    card_last4 "MyString"
    card_type "MyString"
    status "MyString"
    event_last_modified_at "2019-05-21 19:17:03"
    subscription nil
  end
end
