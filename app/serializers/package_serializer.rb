# frozen_string_literal: true

class PackageSerializer < ActiveModel::Serializer
  attributes :created_at, :description, :archive

  def archive
    Rails.application.routes.url_helpers.rails_blob_path(object.archive, only_path: true) if object.archive.attached?
  end
end