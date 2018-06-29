class OperationSerializer < ActiveModel::Serializer
  attributes :id, :name, :driver, :host, :category
  has_many :cases
  has_one :job  
  
  class JobSerializer < ActiveModel::Serializer
    attributes :status, :log
  end
  
  def category
    cat = object.send(:category)
    cat
  end
end