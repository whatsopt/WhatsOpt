# frozen_string_literal: true

class OperationSerializer < ActiveModel::Serializer
  attributes :id, :name, :driver, :category, :status, :success
  has_many :options
  has_many :cases

  def category
    cat = object.send(:category)
    cat
  end
end
