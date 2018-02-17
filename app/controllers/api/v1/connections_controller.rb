
class Api::V1::ConnectionsController < Api::ApiController
  
  class VariableAlreadyExistsError < StandardError
  end
  
  # POST /api/v1/connections
  def create
    @mda = Analysis.find(params[:mda_id])        
    @names = connection_create_params[:names]
    @from_disc = @mda.find_discipline(connection_create_params[:from])
    @to_disc = @mda.find_discipline(connection_create_params[:to])
    begin
      Connection.transaction do
        @names.each do |name|
          check_variable_existence(@mda, @from_disc, @to_disc, name)
         
          vout = @from_disc.output_variables.find_by_name(name)
          unless vout 
            vout = @from_disc.variables.build(name: name, io_mode: "out", 
                      shape: 1, type: "Float", desc: "", units: "")   
          end
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

  # PUT /api/v1/connections/1
  def update
    @connection = Connection.find(params[:id])
    @connection.update!(connection_update_params)      
    head :no_content    
  end
  
  # DELETE /api/v1/connections/1
  def destroy
    @connection = Connection.find(params[:id])
    @connection.destroy_variables
    head :no_content
  end

  private    
  
    def check_variable_existence(mda, disc_from, disc_to, varname)     
      if disc_to.input_variables.find_by_name(varname)
        raise VariableAlreadyExistsError.new("Variable " + varname + " already consumed by " + disc_to.name)
      end
      mda.disciplines.nodes.where.not(id: disc_from).each do |disc|
        if disc.output_variables.find_by_name(varname)
          raise VariableAlreadyExistsError.new("Variable " + varname + " already produced by " + disc.name)
        end
      end      
    end
  
    def connection_create_params
      params.require(:connection).permit(:from, :to, { names: [] })
    end

    def connection_update_params
      params.require(:connection).permit(:name, :type, :shape, :units, :desc, parameter_attributes: [:init])
    end

end
