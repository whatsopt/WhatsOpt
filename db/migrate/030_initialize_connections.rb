class InitializeConnections < ActiveRecord::Migration[5.1]
  def up
    Analysis.all.each do |mda|
      if Connection.of_analysis(mda).count == 0
        puts "Create connections for #{mda.name}"
        if mda.attachment&.mda_cmdows?
          Connection.create_connections(mda, :fullname)
        else
          Connection.create_connections(mda)
        end
      end 
    end
  end
  
  def down
    Connection.all.map(&:destroy!)
  end 
end
