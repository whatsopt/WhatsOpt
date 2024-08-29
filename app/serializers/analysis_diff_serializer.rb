# frozen_string_literal: true

class AnalysisDiffSerializer < ActiveModel::Serializer
  attributes :name, :disciplines

  def disciplines
    object.disciplines.filter_map { |disc|
      if disc.type == Discipline::ANALYSIS or disc.type == Discipline::OPTIMIZATION
        {
          "name": disc.name,
          "sub_analysis": AnalysisDiffSerializer.new(disc.sub_analysis).as_json
        }
      else
        DisciplineDiffSerializer.new(disc).as_json
      end
    }
  end
end
