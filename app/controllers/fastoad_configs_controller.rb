# frozen_string_literal: true

class FastoadConfigsController < ApplicationController
  before_action :set_fastoad_config, only: [:show, :edit, :update, :destroy]

  # GET /fastoad_configs
  def index
    @fastoad_configs = policy_scope(FastoadConfig)
  end

  # GET /fastoad_configs/1
  def show
    if @fastoad_config.custom_analysis
      @fastoad_config.update_custom_modules
    end
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
        render :new
      end
    end
  end

  # PATCH/PUT /fastoad_configs/1
  def update
    if params[:cancel_button]
      redirect_to fastoad_config_url(@fastoad_config), notice: "FAST-OAD update cancelled."
    else
      if @fastoad_config.custom_analysis
      @fastoad_config.update_custom_modules
      else
        mda = @fastoad_config.analysis.create_copy!
        mda.name = mda.name + "_Custom"
        journal = mda.init_journal(current_user)
        journal.journalize(mda, Journal::COPY_ACTION)
        mda.set_owner(current_user)
        mda.save_journal
        @fastoad_config.custom_analysis = mda
      end
      if @fastoad_config.save
        redirect_to mda_url(@fastoad_config.custom_analysis)
      else
        render :show
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
    params.require(:fastoad_config).permit(:name, :version, :module_folders, :input_file, :output_file)
  end
end

