# frozen_string_literal: true

class OperationSerializer < ActiveModel::Serializer
  attributes :id, :name, :driver, :host, :category, :success
  has_many :options
  has_many :cases
  has_one :job

  class OptionSerializer < ActiveModel::Serializer
    attributes :id, :name, :value
  end

  def category
    cat = object.send(:category)
    cat
  end
end
