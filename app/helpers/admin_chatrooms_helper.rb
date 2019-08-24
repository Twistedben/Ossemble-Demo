module AdminChatroomsHelper
  # Main Helper methods for chatroom related helper methods
  
  # Below - Helper method for rendering @mentions inside chatroom messages
  def linked_admins(body, admin)
    content_tag :div do
      body.gsub /@([\w]+\s[\w]+)/ do |match|
        "<span class='py-1 pl-1' style='color: #645496; font-weight: bold;'>#{match}</span>"
      end.html_safe
    end
  end
  
  # Below - Determines whether to show date if the message was longer than a day ago or time if less than a day ago and to add a indication if newer message
  def display_message_owner_time_and_new(message)
    content_tag :div, :class => "message_header col-tier" do
      if message.created_at < 1.day.ago 
        "<b>#{link_to message.admin.name, institute_admin_path(message.admin.institute, message.admin)}</b>  &nbsp; -  &nbsp; <span>#{display_date_in_numbers(message.created_at)}</span>".html_safe
      elsif message.created_at < 1.hour.ago
        "<b>#{link_to message.admin.name, institute_admin_path(message.admin.institute, message.admin)}</b> &nbsp; - &nbsp; <span>#{time_ago_in_words(message.created_at)}</span> ago".html_safe       
      else 
        content_tag :div, :id => "new_message" do
          "<b>#{link_to message.admin.name, institute_admin_path(message.admin.institute, message.admin)}</b> - <span>#{time_ago_in_words(message.created_at)}</span> ago - <i style='color: red'> new </i>".html_safe       
        end
      end 
    end 
  end   
  
  # Below -  Returns number of members in a chatroom plural or singular
  def count_chatroom_members(chatroom) 
    if chatroom.admins.count == 1 
      "#{chatroom.admins.count} Member"
    else 
      "#{chatroom.admins.count} Members"
    end 
  end   
  
end
