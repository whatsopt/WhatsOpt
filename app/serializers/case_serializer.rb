class CaseSerializer < ActiveModel::Serializer

  attributes :values, :varname
  
  def varname
    var = object.send(:variable)
    var.name
  end

end