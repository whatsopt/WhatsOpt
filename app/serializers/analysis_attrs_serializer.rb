# frozen_string_literal: true

class AnalysisAttrsSerializer < ActiveModel::Serializer
  attributes :name, :disciplines_attributes

  def disciplines_attributes
    object.disciplines.filter_map { |disc|
      if disc.type == Discipline::ANALYSIS or disc.type == Discipline::OPTIMIZATION
        {
          "name" => disc.name,
          "type" => disc.type,
          "sub_analysis_attributes": AnalysisAttrsSerializer.new(disc.sub_analysis)
        }
      else
        DisciplineAttrsSerializer.new(disc)
      end
    }
  end
end
