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
        @optimization.config["xlimits"] = params[:optimization][:xlimits].map{|e| e.delete(' ').split(',').map{|s| s.to_i}}
        unless params[:optimization][:options][0].empty? || params[:optimization][:options][1].empty?
          @optimization.config["options"]["mod_obj__regr"] = params[:optimization][:options][0]
          @optimization.config["options"]["optimizer"] = params[:optimization][:options][1]
        end
      else 
        @optimization.config["xtypes"] = params[:optimization][:xtypes].map do |e| 
          arr = e.delete(' ').split(',')
          if arr[0] == "int_type" 
            arr[1] = arr[1].to_i
            arr[2] = arr[2].to_i
          else
            arr[1] = arr[1].to_f
            arr[2] = arr[2].to_f
          end
          {"type" => arr[0], "limits" => [arr[1], arr[2]]}
        end
        @optimization.config["n_obj"] = @optimization.config["xtypes"].length()
        unless params[:optimization][:cstr_specs][0].empty?
          @optimization.config["cstr_specs"] = params[:optimization][:cstr_specs].map do |e|
            arr = e.delete(' ').split(',')
            {"type"=>arr[0], "bound"=>arr[1].to_f, "tol"=>arr[2].to_f}
          end
        end
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
