# frozen_string_literal: true

class MetaModelSpecSerializer < ActiveModel::Serializer
  attributes :id, :name, :owner_email, :created_at, :note, :xlabels, :ylabels

  def name 
    object.analysis.name
  end

  def owner_email
    object.analysis.owner.email
  end

  def note
    object.analysis.note
  end

  def xlabels
    object.xlabels
  end

  def ylabels 
    object.ylabels
  end
end
