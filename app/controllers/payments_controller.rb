class PaymentsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_institute_and_admin, except: [:checkout_new]
  skip_before_action :verify_authenticity_token  

  def index
    # Below - Ensures Super Admin is handling payment only 
    authenticate_super_admin
    @subscription = @institute.subscription
  end

  def checkout_new
    @admin = current_admin 
    @institute = @admin.institute
    subscription_id = params[:sub_id]
    chargebee_id = params[:customer_id]
    plan_id = params[:plan_id]
    @subscription = @institute.subscription
    case plan_id
    when "starter_plan"
      @subscription.plan_id = 2
      @plan_name = "Starter Plan"
      @users = "25"
      @channels = "one Project Channel"
      @extra_features = ""
    when "advanced_plan"
      @subscription.plan_id = 3
      @plan_name = "Advanced Plan"
      @users = "unlimited"
      @channels = "three Project Channels"
      @extra_features = "Also access to Channel Maps and the Stakeholder Directory. "
    when "pro_plan"
      @subscription.plan_id = 4
      @plan_name = "Pro Plan"
      @users = "unlimited"
      @channels = "unlimited Project Channels"
      @extra_features = "Also access to Channel Maps and the Stakeholder Directory. "
    else
    end
    if @subscription.update(chargebee_id: subscription_id, admin_id: @admin.id, status: "active", active: true)
      @institute.update(chargebee_id: chargebee_id)
      flash[:notice] = "Thank you for purchasing the #{@plan_name} subscription for Ossemble. You now can have #{@users} Workplace Users and #{@channels}. #{@extra_features}This plan comes with a 14-day free trial."
      redirect_to workplace_feed_path(@institute, @institute.main_workplace)
    else 
      flash[:alert] = "Something went wrong with your purchase. Please contact us by<a class='title_link' href='mailto:support@ossemble.com?Subject=Subscription%20Purchase%20Issue'> clicking here</a>."
      redirect_to payments_path(@institute)
    end
  end
  
  def create
  end

  def destroy
  end

  private

   # Below -  Ensures only a super admin can access the page
   def authenticate_super_admin 
    # Below - BAsic authorization to ensure super_admin is editing workplace
    unless current_admin.super_admin?
      flash[:alert] = "You don't have permission to access this page."
      redirect_to institute_admin_path(@institute, current_admin)
    end  
  end   

  # Below -  Sets the institute, admin and subscription
  def set_institute_and_admin
    @institute = Institute.friendly.find(params[:institute_id])
    @admin = current_admin
  end   

end
