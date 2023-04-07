# frozen_string_literal: true

class Package < ApplicationRecord
  has_one_attached :archive

  belongs_to :analysis

  def filename 
    if archive.attached?
      archive.attachment.blob.filename
    else
      '<no archive>'
    end
  end



end
