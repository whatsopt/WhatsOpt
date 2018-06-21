class ConvertNameToDriverInOperations < ActiveRecord::Migration[5.2]
  def up
    Operation.all.each do |ope|
      puts "convert name:#{ope.name} to driver:#{ope.name.downcase}" unless ope.name.blank?
      ope.update_column(:driver, ope.name.downcase) unless ope.name.blank?
    end
  end
  
  def down
  end
end
