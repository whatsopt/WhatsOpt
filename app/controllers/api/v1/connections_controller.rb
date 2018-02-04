
class Api::V1::ConnectionsController < Api::ApiController
  
  class VariableAlreadyExistsError < StandardError
  end
  
  # POST /api/v1/connections
  def create
    mda = Analysis.find(params[:mda_id])
    connection = params[:connection]
    name = connection[:name]

    begin
      check_variable_existence(mda, name)
              
      from_disc = Discipline.find(connection[:from_id])
      @varout = from_disc.variables.build(name: name, io_mode: "out", shape: 1, type: "Float", desc: "", units: "")    
      to_disc = Discipline.find(connection[:to_id])
      @varin = to_disc.variables.build(name: name, io_mode: "in", shape: 1, type: "Float", desc: "", units: "")
      
      from_disc.save
      to_disc.save
      
      json_response({fr: from_disc.id, to: to_disc.id, name: name})
    rescue VariableAlreadyExistsError => e
      json_response({ message: e }, :unprocessable_entity)
    end
  end

  # PATCH/PUT /api/v1/disciplines/1
  def update
    head :no_content
  end

  # DELETE /api/v1/disciplines/1
  def destroy
    head :no_content
  end

  private    
  
    def check_variable_existence(mda, name)
      found = false      
      mda.disciplines.nodes.each do |disc|
        found = disc.variables.map(&:name).include?(name)
        if found
          raise VariableAlreadyExistsError.new("Variable " + name + " already in use by node " + disc.name)
        end
      end      
    end
  
end
