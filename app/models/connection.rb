# frozen_string_literal: true

class Connection < ApplicationRecord


  before_validation :_ensure_role_presence
  before_destroy :delete_driver_variables!
  # before_create :announce_creation

  belongs_to :from, -> { includes(:discipline) }, class_name: "Variable"
  belongs_to :to, -> { includes(:discipline) }, class_name: "Variable"

  validates :from, presence: true
  validates :to, presence: true

  scope :active, -> { joins(:from).where(variables: { active: true }) }
  scope :inactive, -> { joins(:from).where(variables: { active: false }) }
  scope :of_analysis, ->(analysis_id) { joins(from: :discipline).where(disciplines: { analysis_id: analysis_id }) }
  scope :from_discipline, ->(discipline_id) { joins(from: :discipline).where(variables: {discipline_id: discipline_id}) }
  scope :to_discipline, ->(discipline_id) { joins(to: :discipline).where(variables: {discipline_id: discipline_id}) }
  scope :with_role, ->(role) { where(role: role) }

  class SubAnalysisVariableNotFoundError < StandardError
  end

  class CannotRemoveConnectionError < StandardError
  end

  # def announce_creation
  #   p "CREATE #{self.from.name} #{self.from.discipline.name} #{self.to.discipline.name}"
  # end

  def self.between(disc_from_id, disc_to_id)
    Connection.joins(:from).where(variables: { discipline_id: disc_from_id }) # .where.not(variables: {type: :String})
              .order("variables.name")
              .joins(:to).where(tos_connections: { discipline_id: disc_to_id })
  end

  def active?
    from.active
  end

  def driverish?
    from.discipline.is_driver? || to.discipline.is_driver?
  end

  def driver
    return from.discipline if from.discipline.is_driver?
    return to.discipline if to.discipline.is_driver?
  end

  def analysis
    from.try(:discipline).try(:analysis)
  end

  def self.create_connection!(from_disc, to_disc, name, sub_analysis_check = true)
    Connection.transaction do
      if sub_analysis_check
        _check_sub_analysis(name, from_disc, WhatsOpt::Variable::IN)
        _check_sub_analysis(name, to_disc, WhatsOpt::Variable::OUT)
      end
      vout = Variable.of_analysis(from_disc.analysis)
                     .where(name: name, io_mode: WhatsOpt::Variable::OUT)
                     .first_or_create!(shape: 1, type: "Float", desc: "", units: "", active: true)
      vout.update(discipline_id: from_disc.id)
      vin = Variable.where(discipline_id: to_disc.id, name: name, io_mode: WhatsOpt::Variable::IN)
                    .first_or_create!(shape: 1, type: "Float", desc: "", units: "", active: true)
      conn = Connection.where(from_id: vout.id, to_id: vin.id).first_or_create!
      # downgrade the role if needed
      if !conn.from.discipline.is_driver? && !conn.to.discipline.is_driver?
        Connection.where(from_id: vout.id).update(role: WhatsOpt::Variable::STATE_VAR_ROLE)
      end
      conn
    end
  end

  # manage exclusively Driver variables if deconnected should be removed
  def delete_driver_variables!
    #p "BEFORE DESTROY #{self.from.name} #{self.from.discipline.name} #{self.to.discipline.name}"
    Connection.transaction do
      to = self.to
      if to.discipline.is_driver?
        # p "Connection to driver: supress #{to.name} driver var"
        to.delete
      end
      conns = Connection.where(from_id: from_id)
      if conns.size == 1 
        from = conns.first.from
        if from.discipline.is_driver?
          # p "Connection only from driver: supress #{from.name} driver var"
          from.delete
        end
      end
    end
  end

  def update_connections!(params)
    Connection.transaction do
      if params[:role]
        # update role of all connections from the source variable
        Connection.where(from_id: from_id).map do |c|
          c.update!(role: params[:role])
        end
        params = params.except(:role)
      end

      # update from variable
      if from.parameter && params[:parameter_attributes]
        params[:parameter_attributes][:id] = from.parameter.id
      end
      if from.scaling && params[:scaling_attributes]
        params[:scaling_attributes][:id] = from.scaling.id
      end
      from.update!(params)

      # update to related variables
      params = params.except(:parameter_attributes, :scaling_attributes)
      Connection.where(from_id: from.id).each do |conn|
        conn.to.update!(params)
      end
    end
  end

  def destroy_connection!(sub_analysis_check = true)
    Connection.transaction do
      if sub_analysis_check && from.discipline.has_sub_analysis?
        if from.outgoing_connections.count == 1
          if to.discipline.is_driver?
            raise CannotRemoveConnectionError, "Connection #{from.name} has to be suppressed" \
              " in #{from.discipline.name} sub-analysis first"
          else # ok variable provided by outer driver now not sub-analysis
            from.update(discipline_id: from.discipline.analysis.driver.id)
          end
        else
          _delete
        end
      elsif sub_analysis_check && to.discipline.has_sub_analysis?
        if from.discipline.is_driver?
          raise CannotRemoveConnectionError, "Connection #{from.name} has to be suppressed" \
            " in #{to.discipline.name} sub-analysis first"
        else
          from.update(discipline_id: from.discipline.analysis.driver.id)
        end
      else
        _delete
      end
    end
  end

  def _delete
    delete
    conns = Connection.where(from_id: from_id)
    Variable.find_by_id(from_id).delete if conns.size == 0
    Variable.find_by_id(to_id).delete
  end

  private
    def self._check_sub_analysis(varname, disc, driver_io_mode)
      if disc.has_sub_analysis?
        var = disc.sub_analysis.driver.variables.where(name: varname, io_mode: driver_io_mode).take
        unless var
          raise SubAnalysisVariableNotFoundError, "Variable #{varname} should be created as an #{driver_io_mode}" \
              " variable of Driver in sub-analysis first"
        end
      end
    end

    def _ensure_role_presence
      if role.blank?
        self.role = WhatsOpt::Variable::STATE_VAR_ROLE
        if from&.discipline&.is_driver?
          self.role = WhatsOpt::Variable::DESIGN_VAR_ROLE
        end
        if to&.discipline&.is_driver?
          self.role = WhatsOpt::Variable::RESPONSE_ROLE
        end
      end
    end
end
