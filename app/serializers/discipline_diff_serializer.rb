# frozen_string_literal: true

class DisciplineDiffSerializer < ActiveModel::Serializer
  attributes :name, :variables

  def variables
    object.output_variables.map { |var|
      {
        "name" => var.name,
        "shape" => var.shape,
        "units" => var.units,
        "role" => var.main_role,
      }
    }.compact
  end
end
