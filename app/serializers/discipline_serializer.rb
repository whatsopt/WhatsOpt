# frozen_string_literal: true

class DisciplineSerializer < ActiveModel::Serializer
  attributes :id, :name, :type

  has_one :endpoint
end
