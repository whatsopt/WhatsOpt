class InitializeVariableRole < ActiveRecord::Migration[5.1]
  
  def up
    Connection.all.each do |conn|
      if conn.from.role.blank?
        if conn.from.discipline.is_driver?  
          role = WhatsOpt::Variable::PARAMETER_ROLE
        elsif conn.to.discipline.is_driver?
          role = WhatsOpt::Variable::RESPONSE_ROLE
        else
          role = WhatsOpt::Variable::PLAIN_ROLE
        end
        conn.from.update_column(:role, role)
      end  
      conn.to.update_column(:role, WhatsOpt::Variable::PLAIN_ROLE)
    end
    Variable.all.each do |var|
      if var.outgoing_connections.empty? and var.incoming_connection.nil?
        p "Variable without connection : ", var
        #var.destroy!
      end 
    end 
  end
  
  def down
    Connection.all.each do |conn|
      conn.from.update_column(:role, "")
      conn.to.update_column(:role, "")
    end
  end
  
end
