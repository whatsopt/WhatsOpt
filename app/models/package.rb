# frozen_string_literal: true

class Package < ApplicationRecord
  PKG_REGEXP = /\A(\w+)-(\d+\.)?(\d+\.)?(\w+)\.tar\.gz\z/

  has_one_attached :archive

  belongs_to :analysis

  validates :filename, format: { with: PKG_REGEXP }
  validates :name, presence: true
  validates :version, presence: true
  validates :archive, presence: true
  validate :archive_mime_type
  validate :filename_uniqueness

  def filename
    if archive.attached?
      archive.attachment.blob.filename.to_s
    else
      "no_archive-0.0.0.tar.gz"
    end
  end

  def name_version
    @basename ||= begin
      filename =~ PKG_REGEXP
      "#{$1}-#{$2}#{$3}#{$4}"
    end
  end

  def name
    @name ||= begin
      filename =~ PKG_REGEXP
      $1
    end
  end

  def version
    @version ||= begin
      filename =~ PKG_REGEXP
      "#{$2}#{$3}#{$4}"
    end
  end

  private
    def archive_mime_type
      if archive.attached? && !archive.content_type.in?(%w(application/gzip))
        errors.add(:archive, "Must be a source dist .tar.gz file")
      end
    end

    def filename_uniqueness
      present = ActiveStorage::Attachment.where(name: "archive").joins(:blob).where(blob: { filename: self.filename })
      # check if we are updating which is ok
      if (present.size > 0) && (present.first.record_id != self.id)
        errors.add(:archive, "'#{self.filename}' already attached to analysis ##{present.first.record.analysis.id}")
      end
    end
end
