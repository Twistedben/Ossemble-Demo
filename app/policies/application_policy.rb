class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end
  
# Begin - Custom class checks like user and city, admin, mod, and logged in.
  # Below - Checks if the instance variable belongs to the user.
    def user_is_owner_of_record? 
      @record.user == user
    end
    # Below -  
    def admin_belongs_to_workplace? 
       
    end   
  # Below - Checks if the user is an admin.
    def is_admin?
      user.admin? || current_admin 
    end

  # Below - Checks if the instance variable belongs to the user and is logged in.
    def user_is_owner_and_present?
      return true if (user.present? && @record.user == user) || (current_admin && @record.user == user)
    end
  # Below - Checks if the user is logged in.
    def user_is_present?
      user.present? && user.guest == false
    end

  # Below - Checks if admin is logged in
    def admin_is_present?
      return true if current_admin
    end 
  # Below - Checks if the user is logged in and instace variable's city is the same as user, making sure user isn't posting elsewhere.  
    def user_is_citizen?
      user.present? && @record.city == user.city
    end
  # Below - Checks if the current user is a mod and the mod of that city.
    def is_mod?
      user.mod? && @record.city == user.city
    end
  # Below - Checks if user is admin, belongs to that city, and is logged in
    def is_admin_of_city? 
      return true if user.present? && user.admin? && @record.city == user.city 
      #return true if current_admin_check? 
    end   
  # Below - Checks if user is guest 
    def is_guest?
      return true if user.guest == true
    end 
  # Below - Checks if user is not guest 
    def is_not_guest?
      return true if user.guest == false
    end 
# End - Custom class checks like user and city, admin, mod, and logged in.
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end
end
