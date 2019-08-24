class ChargesController < ApplicationController
  before_action :authenticate_admin!
  # Below - Before action that sets admin as current admin, the city and the admin's subscription
  before_action :set_city_admin_and_subscription
  
  def new 
    redirect_to city_admin_subscriptions_path(current_admin.institute, current_admin)
  end 
  
  def create
  # Below - Creates the Stripe customer
    if customer = Stripe::Customer.create(
      :email   => params[:stripeEmail],
      :source  => params[:stripeToken],
      :metadata => 
        { 
          :city => @admin.city.name,
          :state => @admin.state,
          :zip_code => @admin.zip,
          :county => @admin.county.name,
          :admin_id => @admin.id,
          :phone_number => @admin.phone_number,
          :address => @admin.address
        }
      )
    # Below - Updates admin's subscription table with the customer ID
      @subscription.customer_id = customer.id
    end 
    
    # Below - Charge succeeds
    if charge = Stripe::Charge.create(
      :customer      => customer.id,
      :amount        => 22500,
      :description   => ' Subscription',
      :currency      => 'usd',
      :receipt_email => @admin.email
    )
      # Below - Charge succeeded so subscription is added 
      subscription = Stripe::Subscription.create({
          customer: customer.id,
          items: [{:plan => "plan_Do1Ec8AnRXhCPG"}],
      })
      # Below - Chnages the citys subscription to City Plus
      @subscription.subscribed = true
      @subscription.plan = "Workplace Beta"
      # Below - Adds in the plan, subscription, product, and charge IDs to the admin's subscription table
      @subscription.plan_id = "plan_Do1Ec8AnRXhCPG"
      @subscription.subscription_id = subscription.id 
      @subscription.charge_id = charge.id 
      # Below - Stores the standard product id determined by Stripe into the subscription table
      @subscription.product_id = "prod_DncGa2lGEf7Jod"
      # Below - Adds 2 to the number of workspaces for a admin since they upgraded to Standard which adds 2 workspaces
      @subscription.workplaces += 2
      if @subscription.save
        flash[:notice] = "Congratulations! You have upgraded to the #{@admin.subscription.plan} Plan."
      else 
        flash[:alert] = "There was an error with your order. Please contact us."
        redirect_to city_admin_subscriptions_path(current_admin.institute, current_admin)
      end 
    else  # Charge fails
      flash[:alert] = e.message
      redirect_to city_admin_subscriptions_path(current_admin.institute, current_admin)
    end 
  end
  
  def destroy 
    
  end
  
  private

  # Below -  Before action that sets admin instance variables, as well as city and subscription based off that
  def set_city_admin_and_subscription 
    @admin = current_admin
    @institute = @admin.institute
  end   
  
end
