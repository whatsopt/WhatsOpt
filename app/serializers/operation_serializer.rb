class OperationSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :cases
end