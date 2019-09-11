# frozen_string_literal: true

class AnalysisSerializer < ActiveModel::Serializer
  attributes :id, :name, :public, :note, :created_at
end
