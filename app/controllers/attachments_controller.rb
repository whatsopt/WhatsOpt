class AttachmentsController < ApplicationController 

  # GET /attachements/1
  def show 
    @attachment = Attachment.find(params[:id])
    case params[:style]
    when "notebook"
      send_file @attachment.data.path(:html), 
                :type => @attachment.data_content_type, 
                :disposition => 'inline'
    else
      flash[:error] = "Attachment style '#{params[:style]}' not handled"
      send_file @attachment.data.path, 
                :type => @attachment.data_content_type
    end
  end

end
