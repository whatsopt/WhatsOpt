# frozen_string_literal: true

class AnalysisSerializer < ActiveModel::Serializer
  attributes :id, :name, :created_at, :owner_email, :notes

  def name 
    object.name
  end

  def owner_email
    object.owner.email
  end

  def notes
    object.note.to_plain_text
  end
end
