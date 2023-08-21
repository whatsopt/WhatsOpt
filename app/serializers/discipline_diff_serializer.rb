# frozen_string_literal: true

class DisciplineDiffSerializer < ActiveModel::Serializer
  attributes :name, :variables

  def variables
    object.output_variables.filter_map { |var|
      {
        "name" => var.name,
        "shape" => var.shape,
        "units" => var.units,
        "role" => var.main_role,
      }
    }
  end
end
