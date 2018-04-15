class CaseSerializer < ActiveModel::Serializer

  attributes :values, :varname, :coord_index
  
  def varname
    var = object.send(:variable)
    var.name
  end

end