class Connection < ApplicationRecord  
  
  belongs_to :from, class_name: 'Variable'
  belongs_to :to, class_name: 'Variable'
  
  validates :from, presence: true
  validates :to, presence: true

  def self.create_connections(mda, based_on = :name)
    varouts = Variable.outputs.joins(discipline: :analysis).where(analyses: {id: mda.id})
    varins = Variable.inputs.joins(discipline: :analysis).where(analyses: {id: mda.id})
    
    varouts.each do |vout|
      if based_on == :fullname
        vins = varins.where(fullname: vout.fullname)
      else
        vins = varins.where(name: vout.name)
      end
      vins.each do |vin|
        Connection.create!(from_id: vout.id, to_id: vin.id)
      end
    end
  end
  
  def self.of_analysis(mda_id)
    Connection.joins(from: :discipline).where(disciplines: {analysis_id: mda_id})
  end 
  
  def self.between(disc_from_id, disc_to_id)
    Connection.joins(:from).where(variables: {discipline_id: disc_from_id}) #.where.not(variables: {type: :String})
              .order('variables.fullname')
              .joins(:to).where(tos_connections: {discipline_id: disc_to_id})
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
      # update from variable
      var_from = Variable.find(from_id)
      if var_from.parameter && params[:parameter_attributes]
        params[:parameter_attributes][:id] = var_from.parameter.id
      end
      var_from.update!(params)

      # update to related variables
      params = params.except(:parameter_attributes)
      
      var_to = Variable.find(to_id)
      if params[:name]
        fullname = var_to.fullname
        params[:fullname] = fullname.gsub(var_to.name, params[:name])
      end 
      
      Connection.where(from_id: var_from.id).each do |conn|
        conn.to.update!(params)
      end      
    end
  end
end
