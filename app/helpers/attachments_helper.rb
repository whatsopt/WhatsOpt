module AttachmentsHelper
 
  def link_to_attachment(attachment)
    result = link_to(attachment.data_file_name, attachment) << " (#{attachment.data_file_size} bytes)"
    result << " : #{attachment.description}" unless record.attachment.blank?
    result
  end
 
  def view_description(attachment)
    if record.attachment.blank?
      "None"
    else
      "#{attachment.description}"
    end
  end
 
end
