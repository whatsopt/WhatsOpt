# frozen_string_literal: true

class Api::V1::OptimizationsController < Api::ApiController
  before_action :set_optimization, only: [:show, :update, :destroy]

  # GET /api/v1/optimizations/1
  def show
    json_response @optim
  end

  # POST /api/v1/optimizations
  def create
    @optim = Optimization.new(optim_params)
    authorize @optim
    @optim.save!
    @optim.create_optimizer
    @optim.set_owner(current_user)
    json_response @optim, :created
  end

  # PATCH /api/v1/optimizations/1
  def update
    @optim.check_optimization_inputs(optim_params)
    inputs = {x: optim_params['x'], y: optim_params['y']}
    @optim.proxy.tell(inputs[:x], inputs[:y])
    res = @optim.proxy.ask
    @optim.update!(inputs: inputs, outputs: {status: res.status, x_suggested: res.x_suggested})
    json_response res
  end

  # DELETE /api/v1/optimizations/1
  def destroy
    @proxy.destroy_optimizer
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