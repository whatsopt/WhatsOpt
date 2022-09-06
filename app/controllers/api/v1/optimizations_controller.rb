# frozen_string_literal: true

class Api::V1::OptimizationsController < Api::ApiController
  before_action :set_optimization, only: [:show, :update, :destroy]

  # GET /api/v1/optimizations/1
  def show
    if @optim.status == Optimization::OPTIMIZATION_ERROR
      json_response({ message: @optim.err_msg }, :bad_request)
    else
      json_response @optim
    end
  end

  # POST /api/v1/optimizations
  def create
    @optim = Optimization.new(optim_params)
    authorize @optim
    if !Optimization.check_optimization_number_for(current_user)
      json_response({ message: "Optimization creation failed: too many optimizations, max nb (#{Optimization::MAX_OPTIM_NUMBER}) reached)" }, :bad_request)
    else
      if @optim.save
        @optim.create_optimizer
        @optim.set_owner(current_user)
        json_response @optim, :created
      else
        skip_authorization
        Rails.logger.error @optim.errors
        json_response({ message: "#{@optim.errors.full_messages}" }, :bad_request)
      end
    end
  end

  # PATCH /api/v1/optimizations/1
  def update
    @optim.check_optimization_inputs(optim_params)
    inputs = { x: optim_params["x"], y: optim_params["y"], with_best: !!optim_params["with_best"] }
    @optim.update!(inputs: inputs, outputs: { status: Optimization::RUNNING, x_suggested: nil })
    OptimizationJob.perform_later(@optim)
    head :no_content
  end

  # DELETE /api/v1/optimizations/1
  def destroy
    @optim.destroy!
    head :no_content
  end

  private
    def set_optimization
      @optim = Optimization.find(params[:id])
      @proxy = @optim.proxy
      authorize @optim
    end

    def optim_params
      params.require(:optimization).permit!
    end
end
