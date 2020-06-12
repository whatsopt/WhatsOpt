# frozen_string_literal: true

class AnalysisItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :owner_email

  def owner_email
    object.owner.email
  end
end
