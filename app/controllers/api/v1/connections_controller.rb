# frozen_string_literal: true

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
    authorize connection.analysis
    connection.analysis.update_connections!(connection, connection_update_params)
    head :no_content
  end

  # DELETE /api/v1/connections/1
  def destroy
    connection = Connection.find(params[:id])
    authorize connection.analysis
    begin
      connection.analysis.destroy_connection!(connection)
      head :no_content
    rescue Analysis::AncestorUpdateError => e
      json_response({ message: e }, :unprocessable_entity)
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

    def connection_create_params
      params.require(:connection).permit(:from, :to, names: [])
    end

    def connection_update_params
      params.require(:connection).permit(:name, :type, :shape, :units, :desc, :active, :role,
                                         parameter_attributes: [:_destroy, :init, :lower, :upper],
                                         scaling_attributes: [:_destroy, :ref, :ref0, :res_ref])
    end
end
