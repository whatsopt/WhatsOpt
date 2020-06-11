# frozen_string_literal: true

class MetaModelSerializer < ActiveModel::Serializer
  attributes :id, :name, :owner_email, :created_at, :note

  def name 
    object.analysis.name
  end

  def owner_email
    object.analysis.owner.email
  end

  def note
    object.analysis.note
  end

  # def x
  #   object.surrogates.map{ |surr| surr.}
  # end
end
