# frozen_string_literal: true

class MetaModelSpecSerializer < ActiveModel::Serializer
  attributes :id, :name, :owner_email, :created_at, :notes, :xlabels, :ylabels

  def name
    object.analysis.name
  end

  def owner_email
    object.analysis.owner.email
  end

  def notes
    object.analysis.note.to_plain_text
  end

  def xlabels
    object.xlabels
  end

  def ylabels
    object.ylabels
  end
end
