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
      send_file @attachment.data.path, 
                :type => @attachment.data_content_type
    end
  end

end
