class ChatroomAdmin < ApplicationRecord
  belongs_to :admin_chatroom
  belongs_to :admin
end
