require 'whats_opt/discipline'

class InitializeKindOfExistingDisciplines < ActiveRecord::Migration[5.1]
  def up
    Discipline.all.each do |d|
      if d.name == WhatsOpt::Discipline::DRIVER_NAME
        d.kind = WhatsOpt::Discipline::NULL_DRIVER
      else 
        d.kind = WhatsOpt::Discipline::ANALYSIS
      end
      d.save
    end 
  end
  
  def down
    Discipline.all.each do |d|
      d.kind = nil
      d.save
    end     
  end
end
