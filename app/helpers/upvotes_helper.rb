module UpvotesHelper
# Main helper module with methods for upvotes.
  
  # Below -  Displays upvote button for admins and workplace
  def display_upvote_button(resource, resource_link) 
    resource_name = resource.class.to_s
    # Begin - Voting check conditional statements: Admin already voted, Belongs to admin, or allowed to vote.
    if belongs_to_admin?(resource)
      form_tag resource_link do
        button_tag "<i class='fas fa-arrow-alt-circle-up'></i>Upvote".html_safe, id: "endorsed_btn", disabled: true, class: 'btn'
      end
    elsif current_admin.voted_for? resource 
      form_tag resource_link do 
        button_tag "<i class='fas fa-arrow-alt-circle-up'></i>Upvoted".html_safe, id: "endorsed_btn", disabled: true, class: 'btn', title: "You've already upvoted this"
      end 
    else # Admin can vote on resource 
      form_tag resource_link do 
        button_tag "<i class='far fa-arrow-alt-circle-up'></i>Upvote".html_safe, id: "endorse_btn", class: 'btn', onclick: "amplitude.getInstance().logEvent('Upvoted a #{resource_name}');"
      end 
    end # End - Voting check
  end   
  
  # Below -  USER: Displays the endorse button for show pages. Passed in it the resource instance variable, the name of the controller and the name of the resource to display on the button itself.
  def display_endorse_button(resource, controller, resource_name, resource_link)
    # Below - User already upvoted the given resource
    if user_voted_for?(resource) 
      if resource_name == "Petition"
        form_tag resource_link do
          button_tag "<i class='fas fa-clipboard-check margin-r-8'></i>Signed".html_safe, id: "endorsed_btn", style: "width: 100px", disabled: true, class: 'btn'
        end
      else # Not a pettition
        form_tag resource_link do
          button_tag "<i class='fas fa-check-circle margin-r-8'></i>Upvoted".html_safe, id: "endorsed_btn", disabled: true, class: 'btn'
        end
      end
    # Below - User owns the resource they're trying to upvote so disables button
    elsif is_current_users?(resource)
      if resource_name == "Petition"
        form_tag resource_link do
          button_tag "<i class='fas fa-file-signature margin-r-8'></i>Sign".html_safe, id: "endorsed_btn", disabled: true, style: "width: 112px", class: 'btn'
        end
      else # Not a pettition
        form_tag resource_link do
          button_tag "<i class='fas fa-arrow-alt-circle-up margin-r-8'></i>Upvote".html_safe, id: "endorsed_btn", disabled: true, class: 'btn'
        end
      end
    elsif is_current_users?(resource) && resource_name == "List"
      if resource_name == "Petition"
        form_tag resource_link do
          button_tag "<i class='fas fa-file-signature margin-r-8'></i>Sign".html_safe, id: "endorsed_btn", disabled: true, style: "width: 112px", class: 'btn'
        end
      else # Not a pettition
        form_tag resource_link do
          button_tag "<i class='fas fa-arrow-alt-circle-up margin-r-8'></i>Upvote".html_safe, id: "endorsed_btn", disabled: true, class: 'btn'
        end
      end
    # Below - User has not filed out their profile entirely, likely because they came from facebook and not a guest. Makes sure the endorse button isnt coming from list views.
    elsif user_not_valid? && resource_name != "List"
      if resource_name == "Petition"
        form_tag resource_link, onclick: "alert('Please visit your update profile page to finish your profile creation');" do 
          button_tag "<i class='fas fa-file-signature margin-r-8'></i>Sign".html_safe, id: "endorse_btn", style: "width: 112px", class: 'btn'
        end 
      else # Not a pettition
        form_tag resource_link, onclick: "alert('Please visit your update profile page to finish your profile creation');" do 
          button_tag "<i class='fas fa-arrow-alt-circle-up margin-r-8'></i>Upvote".html_safe, id: "endorse_btn", class: 'btn'
        end 
      end
    # Below - User is a guest and on show page. Links to nowhere, but allows cookie page store to be redirected back to after signing up.
    elsif is_guest? && resource_name != "List"
      if resource_name == "Petition"
        link_to "<i class='fas fa-file-signature margin-r-8'></i>Sign".html_safe, resource_link, method: :post, id: "endorse_btn", style: "width: 112px", class: 'btn'
      else # Not a pettition
        link_to "<i class='fas fa-arrow-alt-circle-up margin-r-8'></i>Upvote".html_safe, resource_link, method: :post, id: "endorse_btn", class: 'btn'
      end
    else # Below - User can vote on the resource.
      if resource_name == "Complaint"
        if resource.verified_at  # If the complaint hasn't been verified yet, it shows on button "Confirm Complaint" instead of "Upvote".
          form_tag resource_link do 
            button_tag "<i class='fas fa-arrow-alt-circle-up margin-r-8'></i>Upvote".html_safe, id: "", class: 'btn button-up', onclick: "amplitude.getInstance().logEvent('Upvoted a #{resource_name}');"
          end 
        else # Complaint hasn't been verified yet so they're confirming it
          form_tag resource_link do 
            button_tag "<i class='fas fa-arrow-alt-circle-up margin-r-8'></i>Confirm".html_safe, id: "", class: 'btn button-up', onclick: "amplitude.getInstance().logEvent('Confirmed a #{resource_name}');"
          end 
        end
      else # Resource is not a complaint
        if resource_name == "Petition" # Resource is a petition
          form_tag resource_link do 
            button_tag "<i class='fas fa-file-signature margin-r-8'></i>Sign".html_safe, id: "", style: "width: 112px", class: 'btn button-up', onclick: "amplitude.getInstance().logEvent('Signed a #{resource_name}');"
          end 
        else # Resource is not a petition or complaint
          form_tag resource_link do 
            button_tag "<i class='fas fa-arrow-alt-circle-up margin-r-8'></i>Upvote".html_safe, id: "", class: 'btn button-up', onclick: "amplitude.getInstance().logEvent('Upvoted a #{resource_name}');"
          end 
        end
      end 
    end 
  end   
  
  # Below -  With the resource provided, determines what link to give to dfisplay_upvote_button helper
  def provide_workplace_upvote_link(resource) 
    resource_name = resource.class.to_s
    case resource_name
    when "WorkplaceMapPost"
      upvote_workplace_map_post_path(resource.institute, resource.workplace, resource)
    when "WorkplacePost"
      upvote_workplace_post_path(resource.institute, resource.workplace, resource)
    else 
      # Fail Safe
    end 
  end   
        
 
 
end