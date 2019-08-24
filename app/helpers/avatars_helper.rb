module AvatarsHelper
  # Main module helper for rendering avatars across the site.
  
  # Begin - ADMIN: Admin and City Basic Avatars
    # Below - Displays admin avatar or admin default avatar if not provided  for City User show page, city_basic.html.erb
    def display_profile_city_avatar(city_user)
      if city_user.admin.avatar.attached?  # Makes sure admin has or doesn't have an avatar
        image_tag(city_user.admin.avatar.variant(combine_options: {thumbnail: "160x150!", gravity: "center"}), class: 'margin-all-5 circle-avatar')
      else # user doesn't have a profile image
        image_tag "logos/OssembleCityAdminLoginPage.png", alt: "City Profile Pic", style: "height: 130px; width: 120px; border-radius: 30%"
      end
    end   
    # Below - Displays admin avatar or admin default avatar if not provided  
    def display_small_city_avatar(city_user)
      if city_user.avatar.attached?  # Makes sure admin has or doesn't have an avatar
        image_tag(city_user.avatar.variant(combine_options: {thumbnail: "35x35!", gravity: "center"}), class: 'circle-avatar')
      else # user doesn't have a profile image
        image_tag "logos/OssembleCityAdminLoginPage.png", alt: "City Profile Pic", class: "circle-avatar margin-r-5", style: "height: 35px; width: 35px;"
      end
    end
    # Below - Displays admin avatar or admin default avatar if not provided  
    def display_big_city_avatar(admin)
      if admin.avatar.attached?  # Makes sure admin has or doesn't have an avatar
        image_tag(admin.avatar.variant(combine_options: {thumbnail: "105x95!", gravity: "center"}), class: 'circle-avatar')
      else # user doesn't have a profile image
        image_tag "logos/OssembleCityAdminLoginPage.png", alt: "City Profile Pic", style: "height: 105px; width: 85px;"
      end
    end
    # Below - Displays admin avatar or admin default avatar if not provided  
    def display_ap_city_avatar(city_user)
      if city_user.admin.avatar.attached?  # Makes sure admin has or doesn't have an avatar
        image_tag(city_user.admin.avatar.variant(combine_options: {thumbnail: "45x45!", gravity: "center"}), class: 'circle-avatar')
      else # user doesn't have a profile image
        image_tag "logos/OssembleCityAdminLoginPage.png", alt: "City Profile Pic", class: "circle-avatar", style: "height: 45px; width: 45px;"
      end
    end     
  # End - ADMIN: Admin and City Basic Avatars
  
    # Below - Displays a bigger avatar for admin's show page
    def display_admin_profile_avatar(admin)
      if admin.avatar.attached?  # Makes sure admin has or doesn't have an avatar
        image_tag(admin.avatar.variant(combine_options: {thumbnail: "160x150!", gravity: "center"}), class: 'margin-all-5 circle-avatar')
      else # admin doesn't have a profile image
        image_tag "logos/OssembleCityAdminLoginPage.png", alt: "City Profile Pic", class: 'margin-all-5 circle-avatar', style: "height: 130px; width: 120px;"
      end
    end   
     # Below - Displays a bigger avatar for show pages like Post Show, Complaint Show, and Reviews, as well as admin show pages. Check if admin or user. 
    def display_show_avatar(user)
      if user.admin? # An admin
        if user.avatar.attached?  # Makes sure admin has or doesn't have an avatar
          image_tag(user.avatar.variant(combine_options: {thumbnail: "60x60!", gravity: "center"}),  style: "height: 95%", id: 'navbar_profile_avatar', class: 'margin-t-0 margin-r-5')
        else # user doesn't have a profile image
          image_tag "logos/OssembleCityAdminLoginPage.png", alt: "City Profile Pic", id: "navbar_profile_avatar", class: 'margin-t-0 margin-r-5', style: "height: 45px; width: 45px;"
        end
      else # A user
      # Below - Avatar for users
        if user.avatar.attached? # User uploaded one through profile active storage upload
          image_tag(user.avatar.variant(combine_options: {thumbnail: "60x60!", gravity: "center"}), style: "height: 95%", id: 'navbar_profile_avatar', class: 'margin-t-0 margin-r-5')
        elsif user.is_facebook_user? # User has facebook image
          image_tag "#{user.image}?type=large", id: "navbar_profile_avatar", class: "dropdown-toggle", style: "height: 60px; width: 60px;"
        else # user doesn't have a profile image
          image_tag "logos/Owl_FavIcon.png", alt: "Profile Pic", id: "navbar_profile_avatar", class: 'margin-t-0 margin-r-5', style: "height: 45px; width: 45px;"
        end
      end
    end   
    
    # Below - Renders in default owl avatar when a user doesn't have one or an avatar if the user does using current_user, like in navbar. Also for facebook avatar.
    def display_profile_avatar(user)
      if user.avatar.attached?  # User uploaded one through profile active storage upload
        image_tag(user.avatar.variant(combine_options: {thumbnail: "160x150!", gravity: "center"}), class: 'margin-all-5', style: 'border-radius: 50%')
      elsif user.is_facebook_user? # User has facebook image
        image_tag "#{user.image}?type=large", style: "height: 120px; width: 160px; border-radius: 50%"
      elsif is_current_user?(user)  # The user doesn't have an avatar and is on their show page, so upload Avatar button shows.
        content_tag :div, :class => "empty_avatar_box" do
          link_to 'Upload Profile Avatar', edit_user_registration_path(current_user), class: "margin-t-10 btn bg-theme-dark btn-large text-white" 
        end
      else # user doesn't have a profile image
        image_tag "logos/Owl_FavIcon.png", alt: "Profile Pic", style: "height: 140px; width: 150px; border-radius: 30%"
      end
    end   
    
    # Below - Renders in defualt owl avatar when a user doesn't have one or an avatar if the user does using current_user, used in list view for posts.
    def display_list_avatar(user)
      if user.admin? # An admin
        if user.avatar.attached?  # Makes sure admin has or doesn't have an avatar
          image_tag(user.avatar.variant(combine_options: {thumbnail: "35x35!", gravity: "center"}),   id: 'list_avatar', class: "circle-avatar")
        else # user doesn't have a profile image
          image_tag "logos/OssembleCityAdminLoginPage.png", alt: "City Profile Pic", id: 'list_avatar', class: "circle-avatar", style: "height: 35px; width: 35px;"
        end
      else # A user
        if user.avatar.attached? # User uploaded one through profile active storage upload
          image_tag(user.avatar.variant(combine_options: {thumbnail: "35x35!", gravity: "center"}), id: 'list_avatar', class: "circle-avatar")
        elsif user.is_facebook_user? # User has facebook image
          image_tag "#{user.image}?type=large", id: "list_avatar"
        elsif user.admin? # User has facebook image
          image_tag "logos/OssembleCityAdminLoginPage.png", alt: "City Profile Pic", class: "circle-avatar", style: "height: 35px; width: 35px;"
        else # user doesn't have a profile image
          image_tag "logos/Owl_FavIcon.png", alt: "Profile Pic", id: "list_avatar", style: "height 35px; width: 35px;"
        end # End - Avatar uploaded, facebook, or none check.
      end
    end   # End - Displaying list avatar
    
    # Below - Renders in defualt owl avatar when a user doesn't have one or an avatar if the user does using current_user, used in list view for posts.
    def display_message_avatar(user)
      if user.admin? # If user is admin, show just avatar or default image, skip checking facebook image since Admin won't sign up through facebook.
        if user.avatar.attached?  # Admin uploaded one through profile active storage upload
          image_tag url_for(user.avatar.variant(resize: "35x35!")), id: "message_avatar", class: "" 
        else # Admin doesn't have a profile image, so Owl with wig is created
          image_tag "logos/OssembleCityAdminLoginPage.png", alt: "Profile Pic", id: "message_avatar"
        end
      else # User is not admin, so facebook profile image can be checked.  
        if user.avatar.attached? # User uploaded one through profile active storage upload
          image_tag(user.avatar.variant(combine_options: {thumbnail: "35x35!", gravity: "center"}), id: 'message_avatar', class: "")
        elsif user.is_facebook_user? # User has facebook image
          image_tag "#{user.image}?type=large", id: "message_avatar"
        else # user doesn't have a profile image
          image_tag "logos/Owl_FavIcon.png", alt: "Profile Pic", id: "message_avatar"
        end # End - Avatar uploaded, facebook, or none check.
      end
    end   # End - Displaying list avatar

    # Below - Renders in avatars for users on Profile, Users Show page. If there isn't a profile image, allows them to click Upload button.
    def display_nav_avatar(user)
      if user.admin? # If user is admin, show just avatar or default image, skip checking facebook image since Admin won't sign up through facebook.
        if user.avatar.attached?  # Admin uploaded one through profile active storage upload
          image_tag url_for(user.avatar.variant(resize: "50x50!")), id: "navbar_profile_avatar", class: "dropdown-toggle" 
        else # Admin doesn't have a profile image, so Owl with wig is created
          image_tag "logos/OssembleCityAdminLoginPage.png", alt: "Profile Pic", id: "navbar_profile_avatar", style: "height: 50px; width: 50px;"
        end
      else # User is not admin, so facebook profile image can be checked.  
        if user.avatar.attached?  # User uploaded one through profile active storage upload
          image_tag url_for(user.avatar.variant(resize: "50x50!")), id: "navbar_profile_avatar", class: "dropdown-toggle" 
        elsif user.is_facebook_user?  # User has facebook image
            image_tag "#{user.image}?type=large", id: "navbar_profile_avatar", class: "dropdown-toggle", style: "height: 50px; width: 50px;"
        else # user doesn't have a profile image
          image_tag "logos/Owl_FavIcon.png", alt: "Profile Pic", id: "navbar_profile_avatar", style: "height: 50px; width: 50px;"
        end
      end
    end   
    
    # Below - Renders in defualt owl avatar when a user doesn't have one or an avatar if the user does using current_user, used in list view for posts.
    def display_follows_avatar(user)
      if user.avatar.attached? # User uploaded one through profile active storage upload
        image_tag(user.avatar.variant(combine_options: {thumbnail: "35x35!", gravity: "center"}), id: 'navbar_profile_avatar')
      elsif user.is_facebook_user? # User has facebook image
        image_tag "#{user.image}?type=large", id: "navbar_profile_avatar", class: "dropdown-toggle", style: "height: 35px; width: 35px;"
      else # user doesn't have a profile image
        image_tag "logos/Owl_FavIcon.png", alt: "Profile Pic", id: "navbar_profile_avatar", style: "height: 35px; width: 35px;"
      end
    end   
    
    # Below - Renders in defualt owl avatar when a user doesn't have one or an avatar if the user does using current_user. Used in Complaint Verified by
    def display_medium_avatar(user)
      if user.avatar.attached?  # User uploaded one through profile active storage upload
        image_tag url_for(user.avatar.variant(resize: "60x65!")), id: "navbar_profile_avatar", class: "dropdown-toggle" 
      elsif user.is_facebook_user? # User has facebook image
        image_tag "#{user.image}?type=large", id: "navbar_profile_avatar", class: "dropdown-toggle", style: "height: 60px; width: 65px;"
      else # User doesn't have an avatar so default is rendered
        image_tag "logos/Owl_FavIcon.png", alt: "Profile Pic", id: "navbar_profile_avatar", style: "height: 60px; width: 65px;"
      end
    end   
  
    # Below -  Displays Show Image for complaint pics, wul pics, department reviews and posts.
    def display_show_picture(resource)
      link_to image_tag(resource.image.variant(combine_options: {resize: "860x860", gravity: "center"}), id: "uploaded_image" ), resource.image, id: "uploaded_image_link"
    end   

    # Below - Renders in defualt owl avatar when a user doesn't have one or an avatar if the user does using current_user. Used in Complaint Verified by
    def display_comment_avatar(user)
      if user.admin?
        if admin.avatar.attached?  # Makes sure admin has or doesn't have an avatar
          image_tag(admin.avatar.variant(combine_options: {thumbnail: "22x22!", gravity: "center"}), class: 'margin-all-5 circle-avatar')
        else # user doesn't have a profile image
          image_tag "logos/OssembleCityAdminLoginPage.png", alt: "City Profile Pic", style: "height: 15px; width: 15px; border-radius: 30%"
        end
      else
        if user.avatar.attached?  # User uploaded one through profile active storage upload
          image_tag url_for(user.avatar.variant(resize: "22x22!")), id: "comment_avatar", class: "circle-avatar" 
        elsif user.is_facebook_user? # User has facebook image
          image_tag "#{user.image}?type=large", id: "comment_avatar", class: "circle-avatar", style: "height: 15px; width: 15px;"
        else # User doesn't have an avatar so default is rendered
          image_tag "logos/Owl_FavIcon.png", alt: "Profile Pic", id: "comment_avatar", class: "circle-avatar", style: "height: 15px; width: 15px;"
        end
      end
    end   
    
    # Below - Renders in defualt owl avatar when a user doesn't have one or an avatar if the user does using current_user. Used in Complaint Verified by
    def display_admin_comment_avatar(admin)
      if admin.avatar.attached?  # Makes sure admin has or doesn't have an avatar
        image_tag(admin.avatar.variant(combine_options: {thumbnail: "22x22!", gravity: "center"}), class: 'margin-all-5 circle-avatar')
      else # user doesn't have a profile image
        image_tag "logos/OssembleCityAdminLoginPage.png", alt: "City Profile Pic", style: "height: 15px; width: 15px; border-radius: 30%"
      end
    end   
  
end 