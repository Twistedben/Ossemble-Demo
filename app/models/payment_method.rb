class PaymentMethod < ApplicationRecord
  belongs_to :subscription
end
