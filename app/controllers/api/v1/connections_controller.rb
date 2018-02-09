
class Api::V1::ConnectionsController < Api::ApiController
  
  before_action :set_connection, only: [:create, :destroy]
  
  class VariableAlreadyExistsError < StandardError
  end
  
  # POST /api/v1/connections
  def create
    @mda = Analysis.find(params[:mda_id])        
    begin
      @names.each do |name|
        check_variable_existence(@mda, @from_disc, @to_disc, name)
        
        @from_disc.variables.build(name: name, io_mode: "out", shape: 1, type: "Float", desc: "", units: "")    
        @to_disc.variables.build(name: name, io_mode: "in", shape: 1, type: "Float", desc: "", units: "")
        
        Discipline.transaction do
          @from_disc.save!
          @to_disc.save!
        end
      end
      resp = { from: @from_disc.id.to_s, to: @to_disc.id.to_s, names: @names }
      json_response(resp)
    rescue VariableAlreadyExistsError => e
      json_response({ message: e }, :unprocessable_entity)
    end
  end

  # PATCH/PUT /api/v1/connection/1
  def update
    head :no_content
  end

  # POST /api/v1/connection
  def destroy
    @names.each do |name|
      @from_disc.variables.where(fullname: name).take.destroy
      @to_disc.variables.where(fullname: name).take.destroy
    end
    head :no_content
  end

  private    
    def set_connection
      @names = connection_params[:names]
      @from_disc = Discipline.find(connection_params[:from])
      @to_disc = Discipline.find(connection_params[:to])
    end
  
    def check_variable_existence(mda, disc_from, disc_to, varname)     
      if disc_to.input_variables.map(&:name).include?(varname)
        raise VariableAlreadyExistsError.new("Variable " + varname + " already consumed by " + disc_to.name)
      end
      mda.disciplines.nodes.where.not(id: disc_from).each do |disc|
        if disc.output_variables.map(&:name).include?(varname)
          raise VariableAlreadyExistsError.new("Variable " + varname + " already produced by " + disc.name)
        end
      end      
    end
  
    def connection_params
      p params
      params.require(:connection).permit(:from, :to, { names: [] })
    end
end
