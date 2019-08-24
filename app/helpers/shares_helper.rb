module SharesHelper
# Main helpers for sharing and social share gem.
  # Below -  Helper method for displaying the share button from list view, being passed in is the block object as resource, the website, the link to the show page, and the title of the share.
  def display_share_button(resource, website, show_link, title) 
    if resource.image.attached? # Checks if image is attached, and should be included in share
      if website == "Facebook" # Website being passed is facebook with an image
        if resource.class.to_s == "Petition" # Is a petition
          social_share_button_tag(resource.title, :allow_sites => %w(facebook), 
            :image => url_for(resource.image), 
            'data-url' => show_link, 'data-type' => 'link', 
            desc: resource.goal, 'data-facebook-title' => title)
        elsif resource.class.to_s == "Complaint"
          social_share_button_tag(resource.title, :allow_sites => %w(facebook), 
            :image => url_for(resource.image), 
            'data-url' => show_link, 'data-type' => 'link', 
            desc: "#{resource.title} - #{resource.address}: #{resource.description}", 'data-facebook-title' => title)
        else # Not a petition
          social_share_button_tag(resource.title, :allow_sites => %w(facebook), 
            :image => url_for(resource.image), 
            'data-url' => show_link, 'data-type' => 'link', 
            desc: resource.description, 'data-facebook-title' => title)
        end # End - Petition Check
      elsif website == "Twitter" # Twitter website check
        if resource.class.to_s == "Petition" # Is a petition
          social_share_button_tag(resource.title, :allow_sites => %w(twitter), 
            :image => url_for(resource.image), :url => show_link,
            'data-twitter-caption' => resource.goal, 'data-twitter-title' => title)
        else # Not a petition
          social_share_button_tag(resource.title, :allow_sites => %w(twitter), 
            :image => url_for(resource.image), :url => show_link,
            'data-twitter-caption' => resource.title, 'data-twitter-title' => title)
        end # End of petition resource check
      else # Fail safe
      end  # End of website check
    else   # Resource doesn't have an image attached
      if website == "Facebook"
        if resource.class.to_s == "Petition" # Is a petition with facebook and no image
          social_share_button_tag(resource.title, :allow_sites => %w(facebook), 
            'data-url' => show_link, 'data-type' => 'link', 
            desc: resource.goal, 'data-facebook-title' => title)
        elsif resource.class.to_s == "Complaint"
          social_share_button_tag(resource.title, :allow_sites => %w(facebook), 
            'data-url' => show_link, 'data-type' => 'link', 
            desc: "#{resource.title} - #{resource.address}: #{resource.description}", 'data-facebook-title' => title)
        else # Resource is not a petition
          social_share_button_tag(resource.title, :allow_sites => %w(facebook), 
            'data-url' => show_link, 'data-type' => 'link', 
            desc: resource.description, 'data-facebook-title' => title)
        end # End of petition check
      elsif website == "Twitter"
        if resource.class.to_s == "Petition" # Is a petition with facebook and no image
          social_share_button_tag(resource.title, :allow_sites => %w(twitter),
            :url => show_link,
            'data-twitter-caption' => resource.goal, 'data-twitter-title' => title)
        else # Not a petition
          social_share_button_tag(resource.title, :allow_sites => %w(twitter), 
            :url => show_link,
            'data-twitter-caption' => resource.description, 'data-twitter-title' => title)
        end 
      else # Fail safe
      end 
    end
  end   
  
end