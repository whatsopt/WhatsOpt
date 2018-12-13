
class Api::V1::ConnectionsController < Api::ApiController
    
  # POST /api/v1/connections
  def create
    mda = Analysis.find(params[:mda_id])
    authorize mda        
    names = connection_create_params[:names]
    from_disc = mda.disciplines.find(connection_create_params[:from])
    to_disc = mda.disciplines.find(connection_create_params[:to])
    begin
      conns = mda.create_connections!(from_disc, to_disc, names)
      json_response conns, :created
    rescue Connection::SubAnalysisVariableNotFoundError => e
      json_response({ message: e }, :unprocessable_entity)
    end
  end

  # PUT /api/v1/connections/1
  def update
    connection = Connection.find(params[:id])
    authorize connection.from.discipline.analysis
    connection.update_variables!(connection_update_params)      
    head :no_content    
  end
  
  # DELETE /api/v1/connections/1
  def destroy
    connection = Connection.find(params[:id])
    authorize connection.from.discipline.analysis
    begin
      connection.destroy_connection!
      head :no_content
    rescue Connection::CannotRemoveConnectionError => e
      json_response({ message: e }, :unprocessable_entity)
    end
  end

  private    
  
    def check_duplicates(mda, name)
      vouts = Variable.of_analysis(mda).where(name: name, io_mode: WhatsOpt::Variable::OUT)
      if vouts.count > 1
        raise VariableDuplicateError.new("Variable #{name} is duplicated: ids=#{vouts.map(&:id)}. Please call WhatsOpt administrator.")
      end
    end
  
#    def check_variable_existence(mda, disc_from, disc_to, varname)     
#      if disc_to.input_variables.find_by_name(varname)
#        raise VariableAlreadyExistsError.new("Variable " + varname + " already consumed by " + disc_to.name)
#      end
#      mda.disciplines.nodes.where.not(id: disc_from).each do |disc|
#        if disc.output_variables.find_by_name(varname)
#          raise VariableAlreadyExistsError.new("Variable " + varname + " already produced by " + disc.name)
#        end
#      end      
#    end
  
    def connection_create_params
      params.require(:connection).permit(:from, :to, { names: [] })
    end

    def connection_update_params
      params.require(:connection).permit(:name, :type, :shape, :units, :desc, :active, :role,
                                         parameter_attributes: [:_destroy, :init, :lower, :upper])
    end

end
