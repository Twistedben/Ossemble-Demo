class Subscription < ActiveRecord::Base
# Model for Chargebee Subscriptions. This is for the Ossemble plans to reflect the payment done for them on Chargebee and keep track of an admin's plan and access to the website.
  # Allows this model to act as a Chargbee Subscription
  include ChargebeeRails::Subscription
  serialize :chargebee_data, JSON

# Begin - ASSOCIATIONS
  # Below - Associates with admin, belonging to admins and admins having one subscription. 
  belongs_to :admin, optional: true
  # Below - Associates with institue, beloning to institutes and institues has one subscription.
  belongs_to :institute
  # Below - Associates with plan, belonging to plans and plans having many subscriptions.
  belongs_to :plan
# End - ASSOCIATIONS

# Begin - METHODS, CALLBACKS:  


# End - METHODS, CALLBACKS:

end
