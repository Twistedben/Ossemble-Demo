FactoryBot.define do
  factory :address do
    street "MyString"
    street2 "MyString"
    city "MyString"
    state "MyString"
    zip_code "MyString"
    latitude "9.99"
    longitude "9.99"
    verification_info "MyText"
    original_attributes "MyText"
  end
end
