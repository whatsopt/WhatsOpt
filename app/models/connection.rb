# frozen_string_literal: true

class Connection < ApplicationRecord
  include WhatsOpt::PythonUtils

  before_validation :_ensure_role_presence

  belongs_to :from, -> { includes(:discipline) }, class_name: "Variable"
  belongs_to :to, -> { includes(:discipline) }, class_name: "Variable"

  validates :from, presence: true
  validates :to, presence: true

  scope :active, -> { joins(:from).where(variables: { active: true }) }
  scope :inactive, -> { joins(:from).where(variables: { active: false }) }
  scope :of_analysis, ->(analysis_id) { joins(from: :discipline).where(disciplines: { analysis_id: analysis_id }) }
  scope :from_discipline, ->(discipline_id) { joins(from: :discipline).where(variables: { discipline_id: discipline_id }) }
  scope :to_discipline, ->(discipline_id) { joins(to: :discipline).where(variables: { discipline_id: discipline_id }) }
  scope :with_role, ->(role) { where(role: role) }
  
  class SubAnalysisVariableNotFoundError < StandardError
  end

  class CannotRemoveConnectionError < StandardError
  end

  class VariableAlreadyProducedError < StandardError
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
    from&.discipline&.is_driver? || to&.discipline&.is_driver?
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

  # used in journal details
  def name  
    "#{from.discipline.name}.#{from.name} -> #{to.discipline.name}.#{to.name}"
  end

  def self.create_connection!(from_disc, to_disc, name, sub_analysis_check = true)
    Connection.transaction do
      if sub_analysis_check
        _check_sub_analysis(name, from_disc, WhatsOpt::Variable::IN)
        _check_sub_analysis(name, to_disc, WhatsOpt::Variable::OUT)
      end
      vout = Variable.of_analysis(from_disc.analysis)
                     .where(name: name, io_mode: WhatsOpt::Variable::OUT).first
      if vout.blank? 
        vout = Variable.of_analysis(from_disc.analysis)
          .where(name: name, io_mode: WhatsOpt::Variable::OUT)
          .create!(discipline: from_disc,  shape: 1, type: "Float", desc: "", units: "", active: true)
      else
        if vout.discipline.is_driver?
          vout.update!(discipline_id: from_disc.id)
        elsif vout.discipline.id == from_disc.id
          # ok from disc is already producing vout
        else
          raise VariableAlreadyProducedError.new "Variable #{vout.name} already produced by #{vout.discipline.name} discipline"
        end
      end
      
      vin = Variable.where(discipline_id: to_disc.id, name: name, io_mode: WhatsOpt::Variable::IN)
                    .first_or_create!(shape: 1, type: "Float", desc: "", units: "", active: true)
      conn = Connection.where(from_id: vout.id, to_id: vin.id).first_or_create!
      # update role if needed
      if conn.from.discipline.is_driver?
        Connection.where(from_id: vout.id).map { |conn| conn.update!(role: WhatsOpt::Variable::DESIGN_VAR_ROLE) }
      else
        # check if variable connection is connected TO the driver by any means
        conns = Connection.where(from_id: vout.id).joins(:to).where(variables: { discipline_id: conn.analysis.driver.id })
        if conns.blank?
          Connection.where(from_id: vout.id).map { |conn| conn.update!(role: WhatsOpt::Variable::STATE_VAR_ROLE) }
        else
          Connection.where(from_id: vout.id).map { |conn| conn.update!(role: WhatsOpt::Variable::RESPONSE_ROLE) }
        end
      end
      conn
    end
  end

  def update_connections!(params)
    params = params.to_h  # accept string parameters
    _sanitize_connection_params(params)
    Connection.transaction do
      # if shape is changed, destroy distributions if any and set parameter role if uncertain
      if params[:shape]
        proto = Variable.new(name: from.name, shape: params[:shape])
        if from.dim != proto.dim && Connection.where(from_id: from_id).first.role == WhatsOpt::Variable::UNCERTAIN_VAR_ROLE
          params[:role] = WhatsOpt::Variable::PARAMETER_ROLE
        end
      end

      role = nil
      if params[:role]
        # update role of all connections from the source variable
        Connection.where(from_id: from_id).map do |c|
          c.update!(role: params[:role])
        end
        role = params[:role]
        if WhatsOpt::Variable::CONSTRAINT_ROLES.include?(role)  # reset bounds in case of contraninst role
          params[:parameter_attributes] = { init: "", lower: "", upper: "" }
        end
        params = params.except(:role)
      end
      role ||= Connection.where(from_id: from_id).first.role

      # update logic with regard to variable role
      # p "ROLE", role, from, from.distribution
      case role
      when WhatsOpt::Variable::PARAMETER_ROLE
        from.distributions.map(&:mark_for_destruction)

      when WhatsOpt::Variable::DESIGN_VAR_ROLE
        from.distributions.map(&:mark_for_destruction)

      when WhatsOpt::Variable::UNCERTAIN_VAR_ROLE
        if from.distributions.empty?
          if from.parameter && (!from.parameter.lower.blank? && !from.parameter.upper.blank?)
            begin
              lowers = str_to_ary(from.parameter.lower)
              uppers = str_to_ary(from.parameter.upper)
              dists = lowers.zip(uppers).map { |lower, upper| Distribution.uniform_attrs(lower, upper) }
              if dists.size == from.dim
                params.merge!(distributions_attributes: dists)
              elsif dists.size == 1
                params.merge!(distributions_attributes: dists*from.dim)
              end
            rescue ArrayParseError => e
              Rails.logger.info "Error when parsing #{from.parameter.lower} or #{from.parameter.upper}  of #{from.name}: #{e}"
            end
          end
          if params[:distributions_attributes].blank?
            if from.parameter && !from.parameter.init.blank?
              begin
                init_values = str_to_ary(from.parameter.init)
                params.merge!(distributions_attributes: init_values.map { |init| Distribution.normal_attrs(init, "1.0") })
              rescue ArrayParseError => e
                Rails.logger.info "Error when parsing #{from.parameter.init} of #{from.name}: #{e}"
                params.merge!(distributions_attributes: [Distribution.normal_attrs("1.0", "1.0")]*from.dim)
              end
            else
              params[:distributions_attributes] = [Distribution.normal_attrs("1.0", "1.0")]*from.dim
            end
          end
        end
        # p params
        init = params[:parameter_attributes] && params[:parameter_attributes][:init]
        init = from.parameter.init if init.nil? && from.parameter
        params[:parameter_attributes] = { init: init || "", lower: "", upper: "" }
      end

      # update variable
      if from.parameter && !params[:parameter_attributes].blank?
        params[:parameter_attributes] = params[:parameter_attributes].merge!(id: from.parameter.id)
      end
      if from.scaling && !params[:scaling_attributes].blank?
        params[:scaling_attributes] = params[:scaling_attributes].merge!(id: from.scaling.id)
      end
      if from.distributions.size>0 && !params[:distributions_attributes].blank?
        params[:distributions_attributes] = params[:distributions_attributes]
      end

      # params.permit!  # ensure all params transform are permitted
      # p params
      from.update!(params)
      # Note: update only primary attributes, secondary attrs are not propagated to "to" variables
      # FIXME: during analysis copy they are propagated, not a bug for now
      params = params.except(:parameter_attributes, :scaling_attributes, :distributions_attributes)
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
            raise CannotRemoveConnectionError.new "Connection #{from.name} has to be suppressed" \
              " in #{from.discipline.name} sub-analysis first"
          else # ok variable provided by outer driver now not sub-analysis
            from.update(discipline_id: from.discipline.analysis.driver.id)
          end
        else
          _delete
        end
      elsif sub_analysis_check && to.discipline.has_sub_analysis?
        if from.discipline.is_driver?
          raise CannotRemoveConnectionError.new "Connection #{from.name} has to be suppressed" \
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
    conns = Connection.where(from: from)
    # delete from only if it was the last connection from
    if conns.size == 0
      # Rails.logger.warn "----------------- DELETE FROM VAR #{from.name}"
      from.delete
    else
      # special case: as connection to driver is removed role switch to state var for others
      if to.discipline.is_driver?
        conns.map { |conn| conn.update!(role: WhatsOpt::Variable::STATE_VAR_ROLE) }
      end
    end
    # Rails.logger.warn "----------------- DELETE TO VAR #{to.name}"
    to.delete
  end

  private
    def self._check_sub_analysis(varname, disc, driver_io_mode)
      if disc.has_sub_analysis?
        var = disc.sub_analysis.driver.variables.where(name: varname, io_mode: driver_io_mode).take
        unless var
          raise SubAnalysisVariableNotFoundError.new "Variable #{varname} should be created as an #{driver_io_mode}" \
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

    def _sanitize_connection_params(conn_params)
      pr = conn_params
      pr["name"] = sanitize_pystring(pr["name"]) unless pr["name"].blank?
      pr["shape"] = sanitize_pystring(pr["shape"]) unless pr["shape"].blank?
      pr["desc"] = sanitize_pystring(pr["desc"]) unless pr["desc"].blank?
      pr["units"] = sanitize_pystring(pr["units"]) unless pr["units"].blank?
      unless pr["parameter_attributes"].blank?
        prp = pr["parameter_attributes"]
        prp["init"] = sanitize_pystring(prp["init"]) unless prp["init"].blank?
        prp["lower"] = sanitize_pystring(prp["lower"]) unless prp["lower"].blank?
        prp["upper"] = sanitize_pystring(prp["upper"]) unless prp["upper"].blank?
      end
      unless pr["scaling_attributes"].blank?
        prs = pr["scaling_attributes"]
        prs["ref"] = sanitize_pystring(prs["ref"]) unless prs["ref"].blank?
        prs["ref0"] = sanitize_pystring(prs["ref0"]) unless prs["ref0"].blank?
        prs["res_ref"] = sanitize_pystring(prs["res_ref"]) unless prs["res_ref"].blank?
      end
    end
end
