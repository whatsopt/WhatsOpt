class OperationSerializer < ActiveModel::Serializer
  attributes :name
  has_many :cases
end