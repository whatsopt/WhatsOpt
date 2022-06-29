# frozen_string_literal: true

class OptimizationsController < ApplicationController
  before_action :set_optimization, only: [:show]

  # GET /optimizations
  def index
    if params[:optimization_id]
      policy_scope(Optimization)
      @optimization = Optimization.find(params[:optimization_id])
      #current_user.update(analyses_scope_optimization_id: @optimization.id)
      redirect_to optimizations_url
    else
        @optimizations = policy_scope(Optimization)
    end
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
