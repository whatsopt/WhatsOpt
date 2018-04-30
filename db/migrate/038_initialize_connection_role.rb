class InitializeConnectionRole < ActiveRecord::Migration[5.1]
  
  def up
    Connection.all.each do |conn|
      if conn.role.blank?
        if conn.from.discipline.is_driver?  
          role = WhatsOpt::Variable::PARAMETER_ROLE
        elsif conn.to.discipline.is_driver?
          role = WhatsOpt::Variable::RESPONSE_ROLE
        else
          role = WhatsOpt::Variable::PLAIN_ROLE
        end
        conn.update_column(:role, role)
      end  
    end
  end
  
  def down
    Connection.all.each do |conn|
      conn.update_column(:role, "")
    end
  end
  
end
