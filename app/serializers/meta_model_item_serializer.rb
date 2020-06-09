# frozen_string_literal: true

class MetaModelItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :owner_email, :created_at

  def name 
    object.analysis.name
  end

  def owner_email 
    object.analysis.owner.email
  end
end
