# frozen_string_literal: true

class Api::V1::ConnectionsController < Api::V1::ApiMdaUpdaterController
  before_action :set_connection, only: [:update, :destroy]
  before_action :check_mda_update, only: [:update, :destroy]

  after_action :save_journal, only: [:create, :update, :destroy]
  after_action :touch_mda, only: [:create, :update, :destroy]

  # POST /api/v1/connections
  def create
    @mda = Analysis.find(params[:mda_id])
    check_mda_update
    authorize @mda, :update?
    @journal = @mda.init_journal(current_user)
    names = connection_create_params[:names]
    from_disc = @mda.disciplines.find(connection_create_params[:from])
    to_disc = @mda.disciplines.find(connection_create_params[:to])
    begin
      conns = @mda.create_connections!(from_disc, to_disc, names)
      conns.each do |conn|
        @journal.journalize(conn, Journal::ADD_ACTION)
      end
      json_response conns, :created
    rescue Analysis::AncestorUpdateError => e
      json_response({ message: e }, :unprocessable_entity)
    rescue Connection::SubAnalysisVariableNotFoundError, Connection::VariableAlreadyProducedError => e
      json_response({ message: e }, :unprocessable_entity)
    end
  end

  # PUT /api/v1/connections/1
  def update
    begin
      old_attrs = @connection.from.attributes
      @mda.update_connections!(@connection, connection_update_params)
      @journal.journalize_changes(@connection.from, old_attrs)
      head :no_content
    rescue WhatsOpt::Variable::BadShapeAttributeError => e
      json_response({ message: e }, :unprocessable_entity)
    end
  end

  # DELETE /api/v1/connections/1
  def destroy
    @journal.journalize(@connection, Journal::REMOVE_ACTION)
    begin
      @mda.destroy_connection!(@connection)
      head :no_content
    rescue Analysis::AncestorUpdateError => e
      json_response({ message: e }, :unprocessable_entity)
    rescue Connection::CannotRemoveConnectionError => e
      json_response({ message: e }, :unprocessable_entity)
    end
  end

  private
    def set_connection
      @connection = Connection.find(params[:id])
      @mda = @connection.analysis
      authorize @mda, :update?
      @journal = @mda.init_journal(current_user)
    rescue ActiveRecord::RecordNotFound => e  # likely to occur on concurrent update
      begin
        @mda = Analysis.find(params[:mda_id])
        authorize @mda, :update?
        check_mda_update   # raise StaleObjectError
        raise e            # otherwise re-raise
      rescue ActiveRecord::RecordNotFound => e1
        raise e
      end
    end

    def save_journal
      @journal.save
    end

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
                                         parameter_attributes: [:id, :_destroy, :init, :lower, :upper],
                                         scaling_attributes: [:id, :_destroy, :ref, :ref0, :res_ref],
                                         distributions_attributes: [:id, :_destroy, :kind, options_attributes: [:id, :_destroy, :name, :value]])
    end

end
