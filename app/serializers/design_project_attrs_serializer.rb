# frozen_string_literal: true

class DesignProjectAttrsSerializer < ActiveModel::Serializer
  attributes :name, :created_at, :owner_email, :description, :analyses_attributes

  def analyses_attributes
    object.analyses.map do |mda|
      AnalysisAttrsSerializer.new(mda)
    end
  end

  def owner_email
    object.owner.email
  end
end
