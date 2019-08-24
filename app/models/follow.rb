class Follow < ActiveRecord::Base
# Main Model for Following resources and :follows table. Links up with Acts_as_follower gem and the follows_controller.rb controller.
  #extend ActsAsFollower::FollowerLib
  #extend ActsAsFollower::FollowScopes
  
  # Below - PUBLICACTIVITY: Loads in Public Activity Gem for tracking of users' comments
  include PublicActivity::Model
  # Below - Adds Tracking to this model for PubliCActivity
  tracked
  
# Begin - SCOPES: Scopes for Posts.
  # Below - Orders Follows Records that have been recently updated/created to the top.
    default_scope { order(created_at: :desc)}
# End - SCOPES: Scopes for Posts.

  
# Begin - ASSOCIATIONS
  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, :polymorphic => true
  belongs_to :follower,   :polymorphic => true
# End - ASSOCIATIONS

# Begin - CUSTOM METHODS
  def block!
    self.update_attribute(:blocked, true)
  end
# End - CUSTOM METHODS

end
