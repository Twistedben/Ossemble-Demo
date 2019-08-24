class Plan < ApplicationRecord
# Model for Chargbee PLans. They are created in seed.rb file and there are four of them, free (which is when a user first signs up and should last 14 days before forcing to subscription page), starter, advanced and pro.
  # Below - Associates subscriptions as a has many to one relationship. (subscriptions belongs to plan)  
  has_many :subscriptions
end
