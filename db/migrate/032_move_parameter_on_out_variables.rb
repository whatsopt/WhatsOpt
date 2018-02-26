class MoveParameterOnOutVariables < ActiveRecord::Migration[5.1]
  def up
    Parameter.all.each do |param|
      var_in = param.variable
      if var_in.nil?
        param.destroy!
      else
        Connection.where(to_id: var_in.id).each do |conn|
          conn.from.parameter = param
          conn.from.parameter.save!
        end
      end
    end
  end
  
  def down
  end
end
