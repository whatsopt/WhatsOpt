# frozen_string_literal: true

class Connection < ApplicationRecord

  before_validation :_ensure_role_presence
  before_destroy :delete_driver_variables!

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

  def self.print(conns)
    conns.each do |conn|
      puts "Connection #{conn.from.name} from #{conn.from.discipline.name} to #{conn.to.discipline.name}"
    end
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
    params = params.to_h  # accept string parameters
    Connection.transaction do
      role = nil
      if params[:role]
        # update role of all connections from the source variable
        Connection.where(from_id: from_id).map do |c|
          c.update!(role: params[:role])
        end
        role = params[:role]
        params = params.except(:role)
      end
      role ||= Connection.where(from_id: from_id).first.role

      # update logic with regard to variable role
      # p "ROLE", role, from, from.distribution
      case role
      when WhatsOpt::Variable::PARAMETER_ROLE
        if from.parameter
          params.merge!(parameter_attributes: {lower: "", upper: ""})
        end
        params.merge!(distribution_attributes: {_destroy: 1}) if from.distribution

      when WhatsOpt::Variable::DESIGN_VAR_ROLE
        params.merge!(distribution_attributes: {_destroy: 1}) if from.distribution

      when WhatsOpt::Variable::UNCERTAIN_VAR_ROLE
        if from.distribution.blank?
          if from.dim == 1 && from.parameter && (!from.parameter.lower.blank? && !from.parameter.upper.blank?)
            params.merge!(distribution_attributes: 
                            Distribution.uniform_attrs(from.parameter.lower, from.parameter.upper))
          elsif from.dim == 1 && from.parameter && !from.parameter.init.blank?
            params.merge!(distribution_attributes: Distribution.normal_attrs(from.parameter.init, "1.0"))
          else
            params.merge!(distribution_attributes: Distribution.normal_attrs("0.0", "1.0"))
          end
        end 
        # p params
        init = params[:parameter_attributes] && params[:parameter_attributes][:init]
        init = from.parameter.init if init.nil? && from.parameter
        params.merge!(parameter_attributes: {init: init || "", lower: "", upper: "" })
        unless from.dim == 1
          params.merge!(shape: "1")
        end
      end

      # update variable
      if from.parameter && !params[:parameter_attributes].blank?
        params.merge!(parameter_attributes: params[:parameter_attributes].merge!(id: from.parameter.id))
      end
      if from.scaling && !params[:scaling_attributes].blank?
        params.merge!(scaling_attributes: params[:scaling_attributes].merge!(id: from.scaling.id))
      end
      if from.distribution && !params[:distribution_attributes].blank?
        params.merge!(distribution_attributes: params[:distribution_attributes].merge!(id: from.distribution.id))
      end
      # params.permit!  # ensure all params transform are permitted
      # p params
      from.update!(params)

      # Note: update only primary attributes, secondary attrs are not propagated to "to" variables
      # FIXME: during analysis copy they are propagated, not a bug for now 
      params = params.except(:parameter_attributes, :scaling_attributes, :distribution_attributes)
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
