
class Api::V1::ConnectionsController < Api::ApiController
  
  class VariableAlreadyExistsError < StandardError
  end
  
  # POST /api/v1/connections
  def create
    @mda = Analysis.find(params[:mda_id])        
    @names = connection_params[:names]
    @from_disc = @mda.find_discipline(connection_params[:from])
    @to_disc = @mda.find_discipline(connection_params[:to])
    begin
      Connection.transaction do
        @names.each do |name|
          check_variable_existence(@mda, @from_disc, @to_disc, name)
          
          vout = @from_disc.variables.build(name: name, io_mode: "out", shape: 1, type: "Float", desc: "", units: "")    
          vin = @to_disc.variables.build(name: name, io_mode: "in", shape: 1, type: "Float", desc: "", units: "")
          
          vout.save!
          vin.save!
          Connection.create!(from_id: vout.id, to_id: vin.id)
        end
        resp = { from: @from_disc.id.to_s, to: @to_disc.id.to_s, names: @names }
        json_response(resp)
      end
    rescue VariableAlreadyExistsError => e
      json_response({ message: e }, :unprocessable_entity)
    end
  end

  # DELETE /api/v1/connection/1
  def destroy
    @connection = Connection.find(params[:id])
    Connection.transaction do
      Variable.find(@connection.from_id).destroy!
      Variable.find(@connection.to_id).destroy!
      @connection.destroy!
    end
    head :no_content
  end

  private    
  
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
      params.require(:connection).permit(:from, :to, { names: [] })
    end
end
