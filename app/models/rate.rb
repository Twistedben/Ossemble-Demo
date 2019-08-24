class Rate < ActiveRecord::Base
# Model for RatyRate gem.
  belongs_to :rater, class_name: "User"
  belongs_to :rateable, polymorphic: true

  #attr_accessible :rate, :dimension

end
