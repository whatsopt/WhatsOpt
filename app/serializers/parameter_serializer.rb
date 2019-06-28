# frozen_string_literal: true

class ParameterSerializer < ActiveModel::Serializer
  attributes :init, :lower, :upper
end
