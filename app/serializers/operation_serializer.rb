class OperationSerializer < ActiveModel::Serializer
  attributes :id, :name, :category
  has_many :cases
  
  def category
    cat = object.send(:category)
    cat
  end
end