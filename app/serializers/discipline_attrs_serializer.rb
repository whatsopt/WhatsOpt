# frozen_string_literal: true

class DisciplineAttrsSerializer < ActiveModel::Serializer
  attributes :name, :type

  has_many :variables, key: :variables_attributes
end
