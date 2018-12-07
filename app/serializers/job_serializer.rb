class JobSerializer < ActiveModel::Serializer
  attributes :status, :log, :log_count, :start_in_ms, :end_in_ms
  
  def start_in_ms
    object.started_at.to_f * 1000
  end
  def end_in_ms
    object.ended_at.to_f * 1000
  end
end