# frozen_string_literal: true

class AnalysisAttrsSerializer < ActiveModel::Serializer
  attributes :name

  has_many :disciplines, key: :disciplines_attributes, serializer: DisciplineAttrsSerializer
end
