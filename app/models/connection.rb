class Connection < ApplicationRecord  
  
  belongs_to :from, -> { includes(:discipline) }, class_name: 'Variable'
  belongs_to :to, -> { includes(:discipline) }, class_name: 'Variable'
  
  validates :from, presence: true
  validates :to, presence: true

  scope :active, -> { joins(:from).where(variables: {active: true}) }
  scope :inactive, -> { joins(:from).where(variables: {active: false}) }
  scope :of_analysis, -> (analysis_id) { joins(from: :discipline).where(disciplines: {analysis_id: analysis_id}) }
  scope :with_role, -> (role) { where(role: role)}
    
  before_validation :_ensure_role_presence
  before_destroy :delete_related_variables!
    
  class SubAnalysisVariableNotFoundError < StandardError
  end
  
  def self.between(disc_from_id, disc_to_id)
    Connection.joins(:from).where(variables: {discipline_id: disc_from_id}) #.where.not(variables: {type: :String})
              .order('variables.name')
              .joins(:to).where(tos_connections: {discipline_id: disc_to_id})
  end 

  def active?
    from.active
  end
  
  def self.create_connection!(mda, from_disc, to_disc, names)
    Connection.transaction do
      names.each do |name|
        if from_disc.is_sub_analysis?
          var = from_disc.sub_analysis.driver.input_variables.where(name: name).take
          unless var
            raise SubAnalysisVariableNotFoundError.new("Variable #{name} should be created as an input of Driver in sub-analysis first")
          end
        end
        if to_disc.is_sub_analysis?
          var = to_disc.sub_analysis.driver.output_variables.where(name: name).take
          unless var
            raise SubAnalysisVariableNotFoundError.new("Variable #{name} should be created as an output of Driver in sub-analysis first")
          end
        end        
        vout = Variable.of_analysis(mda)
                 .where(name: name, io_mode: WhatsOpt::Variable::OUT)
                 .first_or_create!(shape: 1, type: "Float", desc: "", units: "", active: true)  
        vout.update(discipline_id: from_disc.id)
        vin = Variable.where(discipline_id: to_disc.id, name: name, io_mode: WhatsOpt::Variable::IN)
                 .first_or_create!(shape: 1, type: "Float", desc: "", units: "", active: true)
        Connection.where(from_id: vout.id, to_id: vin.id).first_or_create!
      end
    end
  end
  
  def delete_related_variables!  
    conns_count = Connection.where(from_id: from_id).count
    if conns_count == 1
      Variable.find(from_id).delete
    end
    Variable.find(to_id).delete
  end
    
  def update_variables!(params)
    Connection.transaction do
      if (params[:role])
        # update role of all connections from the source variable
        Connection.where(from_id: from_id).map do |c| 
          c.update!(role: params[:role])
        end
        params = params.except(:role)
      end
      # update from variable
      var_from = Variable.find(from_id)
      if var_from.parameter && params[:parameter_attributes]
        params[:parameter_attributes][:id] = var_from.parameter.id
      end
      var_from.update!(params)

      # update to related variables
      params = params.except(:parameter_attributes)
      var_to = Variable.find(to_id)      
      Connection.where(from_id: var_from.id).each do |conn|
        conn.to.update!(params)
      end      
    end
  end
  
  private
    def _check_sub_analysis(varname, disc, io)
      
    end 
  
    def _ensure_role_presence
      if self.role.blank?
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
