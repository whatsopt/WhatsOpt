# frozen_string_literal: true

class FastoadConfigsController < ApplicationController
  before_action :set_fastoad_config, only: [:show, :edit, :update, :destroy]

  # GET /fastoad_configs
  def index
    @fastoad_configs = policy_scope(FastoadConfig)
  end

  # GET /fastoad_configs/1
  def show
  end

  # GET /fastoad_configs/new
  def new
    @fastoad_config = FastoadConfig.new
    authorize @fastoad_config
  end

  # GET /fastoad_configs/1/edit
  def edit
  end

  # POST /fastoad_configs
  def create
    @fastoad_config = FastoadConfig.new(fastoad_config_params)
    authorize @fastoad_config
    if params[:cancel_button]
      redirect_to fastoad_configs_url, notice: "FAST-OAD Configuration creation cancelled."
    else
      if @fastoad_config.save
        @fastoad_config.set_owner(current_user)
        redirect_to fastoad_configs_url, notice: "FAST-OAD Configuration #{@fastoad_config.name} was successfully created."
      else
        redirect_to new_fastoad_config_url, error: "Something went wrong while creating #{@fastoad_config.name}."
      end
    end
  end

  # PATCH/PUT /fastoad_configs/1
  def update
    if params[:cancel_button]
      redirect_to fastoad_configs_url, notice: "FAST-OAD Configuration update cancelled."
    else
      if @fastoad_config.update(fastoad_config_params)
        redirect_to fastoad_configs_url, notice: "FAST-OAD Configuration #{@fastoad_config.name} was successfully updated."
      else
        render :edit
      end
    end
  end

  # DELETE /fastoad_configs/1
  def destroy
    @fastoad_config.destroy
    redirect_to fastoad_configs_url, notice: "FAST-OAD Configuration #{@fastoad_config.name} was successfully deleted."
  end

private
  def set_fastoad_config
    @fastoad_config = FastoadConfig.find(params[:id])
    authorize @fastoad_config
  end

  def fastoad_config_params
    params.require(:fastoad_config).permit(:name, :description)
  end
end

