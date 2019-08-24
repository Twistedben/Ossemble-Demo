module ApplicationCable
  #class Connection < ActionCable::Connection::Base
  #
  #  identified_by :current_admin
  #  
  #  def connect
  #    self.current_admin = find_verified_admin
  #    logger.add_tags "ActionCable", "Admin: #{current_admin.email}"
  #  end 
  #  
  #  protected 
  #  
  #    def find_verified_admin 
  #      verified_admin = Admin.find_by(id: cookies.signed['admin.id'])
  #      if verified_admin && cookies.signed['admin.expires_at'] > Time.now
  #        verified_admin
  #      else 
  #        reject_unauthorized_connection
  #      end 
  #    end 
  #end    
=begin # Commented out because it's based on users for now. TODO  
 
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected
      
      def find_verified_user
        verified_user = User.find_by(id: cookies.signed['user.id'])
        if verified_user && cookies.signed['user.expires_at'] > Time.now
          verified_user
        else
         
        end
      end
=end
  
end