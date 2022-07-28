# frozen_string_literal: true

class OptimizationsController < ApplicationController
  before_action :set_optimization, only: [:show, :destroy]

  # GET /optimizations
  def index
    @optimizations = policy_scope(Optimization)
  end

  def select
    if params[:delete]
      params[:optimization_request_ids].each do |optimization_selected|
        authorize Optimization.find(optimization_selected.to_i)
        Optimization.find(optimization_selected.to_i).destroy
      end
      redirect_to optimizations_url, notice: params[:optimization_request_ids].length > 1 ? "The #{params[:optimization_request_ids].length} optimizations were successfully deleted." : "The optimization was successfully deleted."
    else
      params[:optimization_request_ids].each do |optimization_selected|
        authorize Optimization.find(optimization_selected)
      end
      redirect_to controller: 'optimizations', action: 'compare', optim_list: params[:optimization_request_ids]
    end
  end

  def show
  end

  def download
    authorize Optimization.find(params[:optimization_id])
    path = "#{Rails.root}/log/optimizations/optim_#{params[:optimization_id]}.log"
    if File.exist?(path) 
      send_file(path) 
    else
      redirect_to optimizations_url, notice: "There isn't a log file"
    end
  end

  def new
    @optimization = Optimization.new
    authorize @optimization
  end

  def create
    if params[:cancel_button]
      skip_authorization
      redirect_to optimizations_url, notice: "Optimization creation cancelled."
    else
      @optimization = Optimization.new(optimization_params)
      if optimization_params[:kind] == "SEGOMOE"
        @optimization.config["n_obj"] = 1
        @optimization.config["xlimits"] = @optimization.str_to_array(optimization_params[:xlimits])
      else 
        @optimization.config["n_obj"] = optimization_params[:n_obj].to_i
      end
      @optimization.outputs["status"] = -1
      authorize @optimization
      if @optimization.save
        @optimization.set_owner(current_user)
        redirect_to optimizations_url, notice: "Optimization ##{@optimization.id} was successfully created."
      else
        render :new
      end
    end
  end

  def compare
    @compare_optimizations_list = []
    params[:optim_list].each do |optimization_selected|
      authorize Optimization.find(optimization_selected)
      @compare_optimizations_list << Optimization.find(optimization_selected)
    end
  end

private
  def set_optimization
    @optimization = Optimization.find(params[:id])
    authorize @optimization
  end

  def optimization_params
    params.require(:optimization).permit(:kind, :n_obj, :xlimits, :x, :y)
  end
end
