class OperationRunChannel < ApplicationCable::Channel
  def subscribed
    @ope = Operation.find(params[:ope_id])
    stream_for @ope
  end

  def unsubscribed
  end
  
end
