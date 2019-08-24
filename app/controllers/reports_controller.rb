class ReportsController < ApplicationController
    
  def new 
    @report = Report.new
  end
 
 
  def create
    @comment = Comment.find(params[:comment_id])
    @report = Report.create(report_params)
    
    @report.reporter_id = current_user.id
    @report.reported_id = @comment.user.id
    @report.offender_id = @comment.id
    if @report.save # If it saves, display Flash message success, if not move to 'else'
      flash[:notice] = "Your report has been submitted successfully."   # Shows a Flash message of success
      redirect_to request.referrer
    else
      flash[:alert] = "There was an error submitting your report."   # Shows a Flash message of error
      redirect_to request.referrer
    end # End - If statement for report creation.
  end

  private
  # Below - Report params for creation of a new report.
  def report_params
    params.require(:report).permit(:name, :description)
  end
  
end 