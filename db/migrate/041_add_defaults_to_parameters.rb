class AddDefaultsToParameters < ActiveRecord::Migration[5.1]
  def change
    change_column_default :parameters, :init, from: nil, to:"" 
    change_column_default :parameters, :upper, from:nil, to:"" 
    change_column_default :parameters, :lower, from:nil, to:"" 
  end
end
