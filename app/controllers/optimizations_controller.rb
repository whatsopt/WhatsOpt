# frozen_string_literal: true

class OptimizationsController < ApplicationController
  before_action :set_optimization, only: [:show, :destroy]

  # GET /optimizations
  def index
    @optimizations = policy_scope(Optimization)
  end

  def destroy_selected
    params[:optimization_request_ids].each do |optimization_selected|
      authorize Optimization.find(optimization_selected.to_i)
      Optimization.find(optimization_selected.to_i).destroy
    end
    redirect_to optimizations_url, notice: params[:optimization_request_ids].length > 1 ? "The #{params[:optimization_request_ids].length} optimizations were successfully deleted." : "The optimization was successfully deleted."
  end


private
  def set_optimization
    @optimization = Optimization.find(params[:id])
    authorize @optimization
  end

  def optimization_params
    params.require(:optimization).permit(:name, :description)
  end
end
