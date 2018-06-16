class AddHostToOperations < ActiveRecord::Migration[5.2]
  def change
    add_column :operations, :host, :string, default:""
  end
end
