class WorkplaceAdminsController < WorkplacesController
# Main controller for Members inside of a work place.  
  append_before_action :authenticate_workplace_membership, only: [:index]
  def index
  end

  def show
  end

  def new
  end

  def create
    @workplace = Workplace.friendly.find(params[:workplace_id])
    @admin = current_admin 
    @member = @workplace.members.build(admin_id: @admin.id, workplace_id: @workplace.id)
    if @member.save
      flash[:notice] = "You've joined this workplace"
      redirect_to request.referrer
    else 
      flash[:alert] = "Couldn't join this workplace"
      redirect_to request.referrer
    end 
  end

  def edit
  end

  def destroy
    @workplace = Workplace.friendly.find(params[:workplace_id])
    @admin = current_admin 
    @member = WorkplaceAdmin.find(params[:id])
    if @member.destroy
      flash[:notice] = "You've removed #{@member.admin.name} from #{@workplace.name}."
      redirect_to request.referrer
    else 
      flash[:alert] = "Couldn't remove this member from #{@workplace.name}."
      redirect_to request.referrer
    end 
  end
  
  private 
  
  def member_params
    params.require(:workplace_admins).permit(:admin_id, :workplace_id, :permission_level)
  end 
  
  
  
end
