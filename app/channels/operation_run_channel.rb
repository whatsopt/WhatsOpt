class OperationRunChannel < ApplicationCable::Channel
  def subscribed
    p params
    @ope = Operation.find(params[:ope_id])
    stream_for @ope
  end

  def unsubscribed
  end
  
end
