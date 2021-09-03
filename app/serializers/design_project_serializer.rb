# frozen_string_literal: true

class DesignProjectSerializer < ActiveModel::Serializer
  attributes :name, :created_at, :owner_email, :description

  has_many :analyses

  def owner_email
    object.owner.email
  end
end