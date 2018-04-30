class VariableSerializer < ActiveModel::Serializer
  attributes :name, :fullname, :io_mode, :shape, :type, :desc, :units, :active
  
  has_one :parameter  
  
  class ParameterSerializer < ActiveModel::Serializer
    attributes :init, :lower, :upper
  end
end
