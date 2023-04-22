# frozen_string_literal: true

class FastoadModulesController < ApplicationController
  before_action :set_fastoad_module, only: [:show, :edit, :update, :destroy]

  # GET /fastoad_configs/:fastoad_config_id/fastoad_modules
  def index
    @fastoad_config = FastoadConfig.find(params[:fastoad_config_id])
    @fastoad_modules = policy_scope(FastoadModule)
  end

  # GET /fastoad_modules/1
  def show
    @fastoad_config = @fastoad_module.fastoad_config
  end

  # GET /fastoad_configs/:fastoad_config_id/fastoad_modules/new
  def new
    @fastoad_config = FastoadConfig.find(params[:fastoad_config_id])
    authorize @fastoad_config
    @fastoad_module = FastoadModule.new()
  end

  # GET /fastoad_modules/1/edit
  def edit
  end

  # POST /fastoad_configs/:fastoad_config_id/fastoad_modules
  def create
    @fastoad_config = FastoadConfig.find(params[:fastoad_config_id])
    authorize @fastoad_config
    @fastoad_module = @fastoad_config.custom_modules.build(fastoad_module_params)
    if @fastoad_module.save
      redirect_to fastoad_config_url(@fastoad_config), notice: "FAST-OAD module #{@fastoad_module.name} was successfully created."
    else
      redirect_to fastoad_config_url(@fastoad_config), error: "Something went wrong while creating #{@fastoad_module.name}.\n#{@fastoad_module.errors.full_messages}"
    end
  end

  # PATCH/PUT /fastoad_modules/1
  def update
    redirect_to fastoad_config_url(@fastoad_config)
  end

  # DELETE /fastoad_modules/1
  def destroy
    authorize @fastoad_module
    @fastoad_module.destroy
    redirect_to fastoad_config_url(@fastoad_config), notice: "Fastoad Module was successfully destroyed."
  rescue FastoadModule::ForbiddenRemovalError => exc
    redirect_to fastoad_config_url(@fastoad_config), alert: exc.message
  end

  private
    def set_fastoad_module
      @fastoad_module = FastoadModule.find(params[:id])
      authorize @fastoad_module
    end

    def fastoad_module_params
      params.require(:fastoad_module).permit(:name, :fastoad_id)
    end
end
