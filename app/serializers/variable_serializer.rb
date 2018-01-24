class VariableSerializer < ActiveModel::Serializer
  attributes :name, :fullname, :io_mode, :shape, :type, :desc
  
  has_one :parameter  
  
  class ParameterSerializer < ActiveModel::Serializer
    attributes :init
  end
end
