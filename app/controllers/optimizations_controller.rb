# frozen_string_literal: true

class OptimizationsController < ApplicationController
  before_action :set_optimization, only: [:show, :destroy]

  # GET /optimizations
  def index
    @optimizations = policy_scope(Optimization)
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
