# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  first_name             :string           not null
#  last_name              :string
#  admin                  :boolean          default(FALSE)
#  subscribed             :boolean          default(TRUE)
#  zip                    :string           default("44107"), not null
#  phone_number           :string
#  address                :string
#  state                  :string           default("Ohio"), not null
#  dob                    :date
#  city_id                :integer          default(1)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  address2               :string
#  gender                 :string
#  provider               :string
#  uid                    :string
#  name                   :string
#  image                  :text
#

FactoryBot.define do
  factory :user, class: User do
    id 1
    first_name "Benjamin"
    last_name "Broestl"
    zip "44107"
    address "15951 Ridge Road"
    state "Ohio"
    city_id 1
    gender "Male"
    dob "1991-02-06"
    email "Benjaminb@example.com"
    provider "facebook"
    uid "10214244817492466"
    password "password"
    confirmed_at Time.now
  end  
  factory :user_2, class: User do
    id 2
    first_name "Matt"
    last_name "Deetz"
    zip "44133"
    address "533 Lee Street"
    state "Ohio"
    city_id 2
    gender "Male"
    dob "1990-10-30"
    email "Mattd@example.com"
    password "password"
    confirmed_at Time.now
  end
  factory :user_3, class: User do
    id 3
    first_name "Joshua"
    last_name "Koszewski"
    zip "44107"
    address "2053 Wascana"
    state "Ohio"
    city_id 1
    gender "Male"
    dob "1990-12-17"
    email "Joshk@example.com"
    password "password"
    confirmed_at Time.now
  end  
  factory :admin_user, class: User do
    id 4
    admin true
    first_name "Benjamin"
    last_name "Broestl"
    zip "44107"
    address "2053 Wascana"
    state "Ohio"
    city_id 1
    gender "Male"
    dob "1991-02-06"
    email "BenjaminJames@example.com"
    password "password"
    confirmed_at Time.now
  end 
  factory :user_4, class: User do
    id 5
    admin true
    first_name "Benjamin"
    last_name "Broestl"
    zip "44107"
    address "2053 Wascana"
    state "Ohio"
    city_id 1
    gender "Male"
    dob "1991-02-06"
    email "BenjaminBJames@example.com"
    password "password"
    confirmed_at Time.now
  end
end
