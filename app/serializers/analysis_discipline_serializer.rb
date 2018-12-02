class AnalysisDisciplineSerializer < ActiveModel::Serializer

  attributes :id, :discipline_id, :analysis_id
  
  def analysis_id
    object.analysis.id
  end

end
