class OperationsController < ApplicationController
  
  def show
    @ope = Operation.find(params[:id])
    @mda = @ope.analysis
  end
  
end
