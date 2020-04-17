# frozen_string_literal: true

class OptimizationSerializer < ActiveModel::Serializer
  attributes :id, :kind, :config, :inputs, :outputs, :created_at, :updated_at
end
