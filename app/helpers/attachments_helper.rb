# frozen_string_literal: true

module AttachmentsHelper
  def link_to_attachment(attachment)
    result = link_to attachment.data_file_name, attachment_path(attachment) << " (#{attachment.data_file_size} bytes)"
    result << " : #{attachment.description}" unless record.attachment.blank?
    result
  end

  def view_description(attachment)
    if attachment.description.blank?
      "None"
    else
      "#{attachment.description}"
    end
  end
end
