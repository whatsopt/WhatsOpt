class InitializeVariableAttributes < ActiveRecord::Migration[5.1]
  def up
    Variable.all.each do |v|
      p v
      desc = "" if v.desc.blank?
      units = "" if v.units.blank?
      fullname = v.name if v.fullname.blank?
      v.update_columns(desc: desc, units: units, fullname: fullname)
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
