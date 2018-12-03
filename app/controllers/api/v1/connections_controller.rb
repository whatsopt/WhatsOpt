
class Api::V1::ConnectionsController < Api::ApiController
  
  class VariableAlreadyExistsError < StandardError
  end

  class VariableDuplicateError < StandardError
  end
    
  # POST /api/v1/connections
  def create
    @mda = Analysis.find(params[:mda_id])
    authorize @mda        
    @names = connection_create_params[:names]
    @from_disc = @mda.disciplines.find(connection_create_params[:from])
    @to_disc = @mda.disciplines.find(connection_create_params[:to])
    p @to_disc
    begin
      Connection.transaction do
        @names.each do |name|
          vout = Variable.of_analysis(@mda)
                   .where(name: name, io_mode: WhatsOpt::Variable::OUT)
                   .first_or_create!(shape: 1, type: "Float", desc: "", units: "", active: true) 
          vout.update(discipline_id: @from_disc.id)
          vin = Variable.where(discipline_id: @to_disc.id, name: name, io_mode: WhatsOpt::Variable::IN)
                   .first_or_create!(shape: 1, type: "Float", desc: "", units: "", active: true)
          c = Connection.where(from_id: vout.id, to_id: vin.id).first_or_create!
        end
        resp = { from: @from_disc.id.to_s, to: @to_disc.id.to_s, names: @names }
        json_response resp, :created
      end
    rescue VariableAlreadyExistsError => e
      json_response({ message: e }, :unprocessable_entity)
    end
  end

  # PUT /api/v1/connections/1
  def update
    @connection = Connection.find(params[:id])
    authorize @connection.from.discipline.analysis
    @connection.update_variables!(connection_update_params)      
    head :no_content    
  end
  
  # DELETE /api/v1/connections/1
  def destroy
    @connection = Connection.find(params[:id])
    authorize @connection.from.discipline.analysis
    @connection.destroy_variables!
    head :no_content
  end

  private    
  
    def check_duplicates(mda, name)
      vouts = Variable.of_analysis(@mda).where(name: name, io_mode: WhatsOpt::Variable::OUT)
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
