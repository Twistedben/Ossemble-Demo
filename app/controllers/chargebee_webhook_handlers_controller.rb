class ChargebeeWebhookHandlersController < ApplicationController
# Controller for handling Chargebee API JSON responses and webhooks. Set inside chargebee_rails.rb intitiliazer.
require 'chargebee'
skip_before_action :verify_authenticity_token  

  def handle
    
    # Getting the json content from the request.
    body = request.body.string

    # Assigning the recieved content to ChargeBee Event object.
    event =  ChargeBee::Event.deserialize(body)   
    
    # Below - Two booleans to keep track of which api json was returned in call from Chargebee
    @subscription_exists = false
    @customer_exists = false
    # Below - Retrieves the customer from chargebee to find the institute subscription.
    if event.content.customer
      # Sets a boolean to keep track of if the customer JSON was included in api call.
      @customer_exists = true
      @customer_id = event.content.customer.id
      @institute = Institute.find_by_chargebee_id(@customer_id)
      @subscription = @institute.subscription
      @admin = @subscription.admin
    # Below - Retrieves the subscription from chargebee to find the institute subscription.
    elsif event.content.subscription
      @subscription_exists = true
      @subscription_id = event.content.subscription.id
      @customer_id = event.content.subscription.customer_id
      @institute = Institute.find_by_chargebee_id(@customer_id)
      @subscription = @institute.subscription
      @admin = @subscription.admin
    else 
      @customer_exists = false
      @subscription_exists = false
    end

    # Below - Case Statement to check the varius types of webhooks coming in and to take DB actions accordingly
    case event.event_type 
    when "subscription_changed"
      plan = Plan.find_by_plan_id("#{event.content.subscription.plan_id}")
      # Below - Updates the admin's subscription based on the plan that has been selected 
      @subscription.update(plan_id: plan.id, event_last_modified_at: Time.now)
      render json: {:message =>  "Changed Subscription Plan" }
    when "subscription_reactivated"
      @subscription.update(status: "#{event.content.subscription.status}", active: "true", event_last_modified_at: Time.now)
      render json: {:message =>  "Subscription Reactivated" }
    when "subscription_cancelled"
      @subscription.update(status: "#{event.content.subscription.status}", active: "false", event_last_modified_at: Time.now)
      render json: {:message =>  "Subscription Cancelled" }
    else 
      render json: {:status => "ok"}
    end 

  end 
 
  def chargebee_rails_event
    
  end

end 