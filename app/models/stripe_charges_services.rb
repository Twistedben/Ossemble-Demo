class StripeChargesServices
  DEFAULT_CURRENCY = 'usd'.freeze
  
  def initialize(user_id, card)
    @user = Admin.friendly.find(user_id)
    @card = card
  end
 
  def create_credit_card
    customer = Stripe::Customer.retrieve(@user.id)
    customer.sources.create(source: generate_token).id
  end
 
  def generate_token
    Stripe::Token.create(
      card: {
        number: @card[:number],
        exp_month: @card[:month],
        exp_year: @card[:year],
        cvc: @card[:cvc]
      }
    ).id
  end
  
end