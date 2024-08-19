# frozen_string_literal: true

class OptimizationsController < ApplicationController
  before_action :set_optimization, only: [:show]

  # GET /optimizations
  def index
    @optimizations = policy_scope(Optimization)
  end

  def select
    if params[:delete]
      params[:optimization_request_ids].each do |optimization_selected|
        authorize Optimization.find(optimization_selected.to_i), :destroy?
        Optimization.find(optimization_selected.to_i).destroy
      end
      redirect_to optimizations_url, notice: params[:optimization_request_ids].length > 1 ? "#{params[:optimization_request_ids].length} optimizations successfully deleted." : "Optimization is successfully deleted."
    else
      kind = Optimization.find(params[:optimization_request_ids].first).kind
      obj_num = Optimization.find(params[:optimization_request_ids].first).n_obj
      error = ""

      params[:optimization_request_ids].each do |optimization_selected|
        authorize Optimization.find(optimization_selected)
        if Optimization.find(optimization_selected).n_obj != obj_num
          error = "Different number of objectives."
        end
        if Optimization.find(optimization_selected).kind != kind
          error = "Different optimizer."
        end
      end

      if error == ""
        redirect_to controller: "optimizations", action: "compare", optim_list: params[:optimization_request_ids]
      else
        redirect_to optimizations_url, alert: "You can't compare these Optimizations : " + error
      end
    end
  end

  def show
  end

  def new
    @optimization = Optimization.new
    authorize @optimization
    optim_num = Optimization.owned_by(current_user).size
    if optim_num > Optimization::MAX_OPTIM_NUMBER
      redirect_to optimizations_url, alert: "You own too many optimizations (#{optim_num}), you must delete some before creating new ones"
    end
  end

  def create
    if params[:cancel_button]
      skip_authorization
      redirect_to optimizations_url, notice: "Optimization creation cancelled."
    else
      @optimization = Optimization.new(optimization_params)
      if optimization_params[:kind] == "SEGOMOE"
        @optimization.n_obj = 1
        @optimization.xlimits = params[:optimization][:xlimits].map { |e| e.delete(" ").split(",").map { |s| s.to_i } }
        unless params[:optimization][:options][0].empty? || params[:optimization][:options][1].empty?
          @optimization.options["mod_obj__regr"] = params[:optimization][:options][0]
          @optimization.options["optimizer"] = params[:optimization][:options][1]
        end
      else
        @optimization.xtypes = params[:optimization][:xtypes].map do |e|
          arr = e.delete(" ").split(",")
          if arr[0] == "int_type"
            arr[1] = arr[1].to_i
            arr[2] = arr[2].to_i
          else
            arr[1] = arr[1].to_f
            arr[2] = arr[2].to_f
          end
          { "type" => arr[0], "limits" => [arr[1], arr[2]] }
        end
        @optimization.n_obj = params[:optimization][:n_obj].to_i
        unless params[:optimization][:cstr_specs][0].empty?
          @optimization.cstr_specs = params[:optimization][:cstr_specs].map do |e|
            arr = e.delete(" ").split(",")
            { "type" => arr[0], "bound" => arr[1].to_f, "tol" => arr[2].to_f }
          end
        end
      end
      @optimization.status = -1
      authorize @optimization
      if !Optimization.check_optimization_number_for(current_user)
        redirect_to new_optimization_url, error: "Max optimization number reached (#{Optimization::MAX_OPTIM_NUMBER})."
      else
        if @optimization.save
          @optimization.set_owner(current_user)
          redirect_to optimizations_url, notice: "Optimization ##{@optimization.id} was successfully created."
        else
          redirect_to new_optimization_url, error: "Something went wrong, optimization creation failed."
        end
      end
    end
  end

  def edit
    set_optimization
  end

  def update
    set_optimization
    if params[:cancel_button]
      redirect_to optimization_path(@optimization), notice: "Optimization update cancelled."
    else
      errors = ""
      params[:optimization][:inputs][:x].each_with_index do |x, i|
        new_x = x.delete(" ").split(",").map { |s| s.to_f }
        new_y = params[:optimization][:inputs][:y][i].delete(" ").split(",").map { |s| s.to_f }

        if new_x.length == @optimization.xlimits.length + @optimization.xtypes.length
          if new_y.length == @optimization.n_obj
            if @optimization.inputs.empty? || @optimization.inputs["x"].nil?
              @optimization.inputs = { "x" => [], "y" => [] }
            end
            @optimization.inputs["x"].append(new_x)
            @optimization.inputs["y"].append(new_y)
          else
            errors += "the input n°#{i + 1} has a wrong y dimention, expected #{@optimization.n_obj}, got #{new_y.length}. "
          end
        else
          if new_x.length != 0
            errors += "the input n°#{i + 1} has a wrong x dimension, expected #{@optimization.xlimits.length + @optimization.xtypes.length}, got #{new_x.length}. "
          end
        end
      end
      if errors != ""
        redirect_to edit_optimization_path(@optimization), alert: "Optimization update failed, #{errors}"
      elsif @optimization.save
        redirect_to optimization_path(@optimization), notice: "Optimization update was succesful, added #{params[:optimization][:inputs][:x].length} inputs"
      else
        redirect_to optimization_path(@optimization), alert: "Optimization update failed due to an unknown error"
      end
    end
  end

  def compare
    @compare_optimizations_list = []
    if params[:optim_list].length > 1
      params[:optim_list].each do |optimization_selected|
        authorize Optimization.find(optimization_selected)
        @compare_optimizations_list << Optimization.find(optimization_selected)
      end
    else
      authorize Optimization.find(params[:optim_list].first)
      redirect_to optimization_path(Optimization.find(params[:optim_list].first))
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
