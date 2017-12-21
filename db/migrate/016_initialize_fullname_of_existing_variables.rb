class InitializeFullnameOfExistingVariables < ActiveRecord::Migration[5.1]
  def up
    Variable.all.each do |v|
      v.fullname = v.name
      v.save
    end 
  end
  
  def down
    Variable.all.each do |v|
      v.fullname = nil
      v.save
    end     
  end
end
