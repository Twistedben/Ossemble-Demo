# Badge upgrade helper
module BadgesHelper
  def upgrade_badge(user, badge_name, score)
    case badge_name
    when 'Ownership'
      upgrade_ownership(user, score)
    when 'Persistence'
      upgrade_persistence(user, score)
    when 'Communication'
      upgrade_communication(user, score)
    when 'Gratitude'
      upgrade_gratitude(user, score)
    end
  end

  # ownership badge rules
  def upgrade_ownership(user, score)
    @ownership = user.ownership
    @ownership.score += score
    if @ownership.level <= 9
      if @ownership.score >= (250 * (@ownership.level + 1))
        @ownership.score = @ownership.score - (250 * (@ownership.level + 1))
        @ownership.level += 1
      end
    end
    @ownership.save
  end

  # persistence badge rules
  def upgrade_persistence(user, score)
    @persistence = user.persistence
    @persistence.score += score
    if @persistence.level <= 9
      if @persistence.score >= (75 * (@persistence.level + 1))
        @persistence.score = @persistence.score - (75 * (@persistence.level + 1))
        @persistence.level += 1
      end
    end
    @persistence.save
  end

  # commucation badge rules
  def upgrade_communication(user, score)
    @communication = user.communication
    @communication.score += score
    if @communication.level <= 9
      if @communication.score >= (100 * (@communication.level + 1))
        @communication.score = @communication.score - (100 * (@communication.level + 1))
        @communication.level += 1
      end
    end
    @communication.save
  end

  # gratitude badge rules
  def upgrade_gratitude(user, score)
    @gratitude = user.gratitude
    @gratitude.score += score
    if @gratitude.level <= 9
      if @gratitude.score >= (100 * (@gratitude.level + 1))
        @gratitude.score = @gratitude.score - (100 * (@gratitude.level + 1))
        @gratitude.level += 1
      end
    end
    @gratitude.save
  end
    
  # Below -  Displays uynique (bonus) badges based on the title passed in.
  def display_unique_badge(title, user) 
    case title 
    when "Pioneer"
      image_tag "badges/OssemblePioneering.svg", id: "pioneer_badge", class: "image awarded_badge", title: "Pioneer: Was there when it all began and verified their account."
    when "Ally"
      image_tag "badges/OssembleAllies.svg", id: "ally_badge", class: "image awarded_badge", title: "Ally: Has some allies and has made some friends!"
    when "Friend of the City"
      image_tag "badges/OssembleFriendoftheCity.svg", id: "friend_badge", class: "image awarded_badge", title: "Friend Of The City: Can contribute to another city."
    when "Moderator"
      image_tag "badges/OssembleModerators.svg", id: "moderator_badge", class: "image awarded_badge", title: "Moderator: A Moderator of a city."
    else 
      #fail safe
    end 
  end   
  # Below -  Displays badge percentage to next level up by deviding score by level, and returns a whole number percentage.
  def badge_percentage(user, badge) 
    case badge 
    when "ownership"
      score = user.ownership.score 
    when "persistence"
      score = user.persistence.score 
    when "communication"
      score = user.communication.score 
    when "gratitude"
      score = user.gratitude.score 
    else
      #Failsafe
    end
    level = user.badge_ding_threshold(badge)
    value = score.to_f / level.to_f
    percentage = value * 100
    return percentage.to_i
  end  
  # Below -  Displays badge progress, score out of total level threshold
  def badge_progress(user, badge)
    case badge
    when "ownership"
      score = "#{user.ownership.score}"
    when "persistence"
      score = "#{user.persistence.score}"
    when "communication"
      score = "#{user.communication.score}"
    when "gratitude"
      score = "#{user.gratitude.score} "
    else 
      # Renders a failsafe
    end
    "#{score} / #{user.badge_ding_threshold(badge)}"
  end   
end
