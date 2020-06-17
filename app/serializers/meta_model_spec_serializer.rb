# frozen_string_literal: true

class MetaModelSpecSerializer < ActiveModel::Serializer
  attributes :id, :surrogate_kind, :reference_analysis, :xlabels, :ylabels

  def surrogate_kind
    object.default_surrogate_kind
  end

  def reference_analysis
    AnalysisSerializer.new(object.analysis).as_json
  end

  def xlabels
    object.xlabels
  end

  def ylabels
    object.ylabels
  end
end
