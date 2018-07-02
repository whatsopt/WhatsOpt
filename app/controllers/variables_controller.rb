class VariablesController < ApplicationController
#  before_action :set_variable, only: [:show, :edit, :update, :destroy]
#
#  # GET /variables
#  def index
#    @variables = Variable.all
#  end
#
#  # GET /variables/1
#  def show
#  end
#
#  # GET /variables/new
#  def new
#    @variable = Variable.new
#  end
#
#  # GET /variables/1/edit
#  def edit
#  end
#  
#  # POST /variables
#  def create
#    @variable = Variable.new(variable_params)
#    if @variable.save
#      redirect_to @variable, notice: 'Variable was successfully created.' 
#    else
#      render :new
#    end
#  end
#
#  # PATCH/PUT /variables/1
#  def update
#    if @variable.update(variable_params)
#      redirect_to @variable, notice: 'Variable was successfully updated.'
#    else
#      render :edit
#    end
#  end
#
#  # DELETE /variables/1
#  def destroy
#    @variable.destroy
#    redirect_to variables_url, notice: 'Variable was successfully destroyed.' 
#  end
#
#  private
#    # Use callbacks to share common setup or constraints between actions.
#    def set_variable
#      @variable = Variable.find(params[:id])
#      authorize @variable
#    end
#
#    # Never trust parameters from the scary internet, only allow the white list through.
#    def variable_params
#      params.require(:variable).permit(:name, :discipline_id, :io_mode, :type, :shape, :units, :desc, parameter_attributes: [:init])
#    end
end
