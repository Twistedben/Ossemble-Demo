class FollowsController < ApplicationController
  # Below - Before action that sets the followable object.
  before_action :set_followable, except: [:content_to_follow]
  
  # Below -  Set up for a new user after updating their profile
  def content_to_follow
  	@followable ||= Subtopic.friendly.find(params[:subtopic_id]) if params[:subtopic_id]
		@follows ||= current_user.follow(@followable)
		@followable.create_activity :follow, owner: current_user, recipient: @followable 
  end   
  

  def create
		if @follows ||= current_user.follow(@followable)
			# PROGRAMMER'S NOTE: When City following is added, another line of create activity will have to be added.
			# Begin -  If Statement Determines if a subtopic or user is being followed and to create activity or punches accordingly.
			#upgrade_badge(current_user, 'Communication', 5) # Upgrade the ownership badge
			if current_admin # FOllow for Admin 
				if is_admin_resource?(@followable) # The content being followed is an admin workplace post, report or suggestion
					# Below - Creates an activity for a user following a resource unless it's a User or Post being followed. This goes into public_activity -> RESOURCE -> _follow.html.erb
					@followable.create_activity :follow, owner: current_admin, recipient: @followable.admin 
					# Below - Adds 1 to trending counter when resource is followed unless it's a user since users don't have trending yet.
					@followable.punches.create(hits: 1)
					Notification.create(recipient: @followable.admin, actor: current_admin, action: "followed", notifiable: @followable)
				else # The following content is user related, like post or complaint or petition
					if @follows.followable_type == "User" || @follows.followable_type == "Subtopic"  # Following is done on a a user or subtopic.
						# Below - Creates an activity for a user following a user. This goes into public_activity -> user -> _follow.html.erb & subtopic -> _follow.html.erb
						@followable.create_activity :follow, owner: current_admin, recipient: @followable
						Notification.create(recipient: @followable, actor: current_admin, action: "followed", notifiable: @followable)
					else # Following is done on a Post, COmplaint, or Petition or Concern
						# Below - Creates an activity for a user following a resource unless it's a User or Post being followed. This goes into public_activity -> RESOURCE -> _follow.html.erb
						@followable.create_activity :follow, owner: current_admin, recipient: @followable.user 
						# Below - Adds 1 to trending counter when resource is followed unless it's a user since users don't have trending yet.
						@followable.punches.create(hits: 1)
						Notification.create(recipient: @followable.user, actor: current_admin, action: "followed", notifiable: @followable)
					end
				end # End - Check of resource being an admin's or users
			else # FOllow for users 
				if @follows.followable_type == "User" || @follows.followable_type == "Subtopic"  # Following is done on a a user or subtopic.
					# Below - Creates an activity for a user following a user. This goes into public_activity -> user -> _follow.html.erb & subtopic -> _follow.html.erb
					@followable.create_activity :follow, owner: current_user, recipient: @followable
					 Notification.create(recipient: @followable, actor: current_user, action: "followed", notifiable: @followable)
	
				else # Following is done on a Post, COmplaint, or Petition or Concern
					# Below - Creates an activity for a user following a resource unless it's a User or Post being followed. This goes into public_activity -> RESOURCE -> _follow.html.erb
					@followable.create_activity :follow, owner: current_user, recipient: @followable.user 
					# Below - Adds 1 to trending counter when resource is followed unless it's a user since users don't have trending yet.
					@followable.punches.create(hits: 1)
						Notification.create(recipient: @followable.user, actor: current_user, action: "followed", notifiable: @followable)
				end
			end
			respond_to do |format|
				# End - Unless statement
				format.html do
					flash[:notice] = "You have followed this."
					redirect_to request.referrer
				end  # HTML Do Block
				format.js # Calls create.js.erb in follows view folder AJAX Code.
			end # Respond to block
		else   # save fails
			respond_to do |format|
				# Below - Renders a js popup alert saying resource couldnt be followed.
    		format.js { render :file => "/follows/fail.js.erb" }
			end
		end  # If Statement
		
  end

  def destroy
		if @follows ||= current_user.stop_following(@followable)
				# Below - Removes 1 to trending counter when resource is followed unless it's a user or subtopic that don't have trending yet.
			@followable.punches.create(hits: 1) unless @follows.followable_type == "User" || @follows.followable_type == "Subtopic"
			respond_to do |format|
				format.html do
					flash[:notice] = "You have unfollowed this."
					redirect_to request.referrer
				end  # HTML Do Block
				format.js # Calls create.js.erb in follows view folder AJAX Code.
			end # Respond to block
		else   # save fails
			respond_to do |format|
				# Below - Renders a js popup alert saying resource couldnt be followed.
    		format.js { render :file => "/follows/fail.js.erb" }
			end
		end  # If Statement
  end
  
	private 
	
		# Below -  Sets the followable object determinitive on what object is looking to be followed.
		def set_followable
			 @followable ||= Petition.friendly.find(params[:petition_id]) if params[:petition_id]
			 @followable ||= Complaint.friendly.find(params[:complaint_id]) if params[:complaint_id]
			 @followable ||= Post.friendly.find(params[:post_id]) if params[:post_id]
			 @followable ||= Subtopic.friendly.find(params[:subtopic_id]) if params[:subtopic_id]
			 @followable ||= User.friendly.find(params[:user_id]) if params[:user_id]
			 @followable ||= Concern.friendly.find(params[:concern_id]) if params[:concern_id]
			 @followable ||= WorkplaceSuggestion.friendly.find(params[:workplace_suggestion_id]) if params[:workplace_suggestion_id]
			 @followable ||= WorkplacePost.friendly.find(params[:workplace_post_id]) if params[:workplace_post_id]
			 @followable ||= WorkplaceReport.friendly.find(params[:workplace_report_id]) if params[:workplace_report_id]
			 #@followable ||= current_user.city.subtopics if current_page?(edit_user_registration_path(current_user))
		end   
	
end