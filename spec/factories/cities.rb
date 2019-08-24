# == Schema Information
#
# Table name: cities
#
#  id        :integer          not null, primary key
#  name      :string           not null
#  zip       :string           not null
#  map_id    :integer
#  county_id :integer
#  state     :string
FactoryBot.define do
  factory :city do
    id 1
    name "Lakewood"
    zip '44107'
    state 'Ohio'
    latitude 41.482473
    longitude -81.79826
  end  
  factory :city_2, class: City do
    id 2
    name "North Royalton"
    zip '44133'
    state 'Ohio'
    latitude 41.313664
    longitude -81.724574
  end
  factory :city_3, class: City do 
    id 3
    name "Cleveland"
    zip '44135'
    state 'Ohio'
    latitude 42.482473
    longitude -85.79826
  end 
  factory :city_4, class: City do 
    id 4
    name "Rocky River"
    zip '44335'
    state 'Ohio'
    latitude 44.2473
    longitude -88.79826
  end 
end