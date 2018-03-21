class AddActiveToVariables < ActiveRecord::Migration[5.1]
  def change
    add_column :variables, :active, :boolean, default: true
  end
end
