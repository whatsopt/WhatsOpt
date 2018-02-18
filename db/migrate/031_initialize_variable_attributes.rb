class InitializeVariableAttributes < ActiveRecord::Migration[5.1]
  def up
    Variable.all.each do |v|
      p v
      v.desc = "" if v.desc.blank?
      v.units = "" if v.units.blank?
      v.fullname = v.name if v.fullname.blank?
      v.save!
    end

    Parameter.all.each do |param|
      p param
      param.init = "" if param.init.blank?
      param.lower = "" if param.lower.blank?
      param.upper = "" if param.upper.blank?
      param.save!
    end
  end
  
  def down
  end
end
