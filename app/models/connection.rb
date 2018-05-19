class Connection < ApplicationRecord  
  
  belongs_to :from, class_name: 'Variable'
  belongs_to :to, class_name: 'Variable'
  
  validates :from, presence: true
  validates :to, presence: true

  scope :active, -> { joins(:from).where(variables: {active: true}) }
  scope :inactive, -> { joins(:from).where(variables: {active: false}) }
  scope :of_analysis, -> (analysis_id) { joins(from: :discipline).where(disciplines: {analysis_id: analysis_id}) }
  scope :with_role, -> (role) { where(role: role)}
    
  before_validation :_ensure_role_presence  
    
  def self.create_connections(mda)
    varouts = Variable.outputs.joins(discipline: :analysis).where(analyses: {id: mda.id})
    varins = Variable.inputs.joins(discipline: :analysis).where(analyses: {id: mda.id})
    
    varouts.each do |vout|
      vins = varins.where(name: vout.name)
      vins.each do |vin|
        role = WhatsOpt::Variable::PLAIN_ROLE
        if vout.discipline.is_driver?
          role = WhatsOpt::Variable::PARAMETER_ROLE
        end
        if vin.discipline.is_driver?
          role = WhatsOpt::Variable::RESPONSE_ROLE
        end
        Connection.create!(from_id: vout.id, to_id: vin.id, role: role)
      end
    end
  end
    
  def self.between(disc_from_id, disc_to_id)
    Connection.joins(:from).where(variables: {discipline_id: disc_from_id}) #.where.not(variables: {type: :String})
              .order('variables.name')
              .joins(:to).where(tos_connections: {discipline_id: disc_to_id})
  end 

  def active?
    from.active
  end
  
  def destroy_variables!  
    Connection.transaction do
      conns_count = Connection.where(from_id: from_id).count
      if conns_count == 1
        Variable.find(from_id).destroy!
      end
      Variable.find(to_id).destroy!
      destroy!
    end
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
  
    def _ensure_role_presence
      if self.role.blank?
        self.role = WhatsOpt::Variable::PLAIN_ROLE
        if from&.discipline&.is_driver?
          self.role = WhatsOpt::Variable::DESIGN_VAR_ROLE
        end
        if to&.discipline&.is_driver?
          self.role = WhatsOpt::Variable::RESPONSE_ROLE
        end        
      end
    end
  
end
