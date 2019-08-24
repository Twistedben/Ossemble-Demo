class AdminPolicy < ApplicationPolicy #Struct.new(:user, :admin)
  class Scope < Scope
    def resolve
      scope
    end
  end
=begin 
  def show?
     is_admins_city?
  end
  def petitions?
    is_admins_city?
  end
  def profiles?
    is_admins_city?
  end
  def departments?
    is_admins_city?
  end
  def complaints?
    is_admins_city?
  end
=end
end
