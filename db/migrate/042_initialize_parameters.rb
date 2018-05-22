class InitializeParameters < ActiveRecord::Migration[5.1]
  def up
    Parameter.all.each do |param|  
      if param.variable.nil?
        param.destroy!
      else
        param.init = "" if param.init.nil?
        param.lower = "" if param.lower.nil?
        param.upper = "" if param.upper.nil?
        param.save!
      end 
    end
  end
  
  def down
  end
end
