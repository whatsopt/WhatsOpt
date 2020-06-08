# frozen_string_literal: true

class MetaModelItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :owner, :created_at

  def name 
    object.analysis.name
  end

  def owner 
    object.analysis.owner
  end
end
