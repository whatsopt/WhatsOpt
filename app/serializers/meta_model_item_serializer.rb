# frozen_string_literal: true

class MetaModelItemSerializer < ActiveModel::Serializer
  attributes :id, :reference_analysis

  def reference_analysis
    AnalysisSerializer.new(object.analysis).as_json
  end
end
