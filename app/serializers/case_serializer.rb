class CaseSerializer < ActiveModel::Serializer

  attributes :values, :varname, :coord_index
  
  def varname
    var = object.send(:variable)
    if var
      var.name
    else
      "unknown_#{object.variable_id}"
    end
  end

end
