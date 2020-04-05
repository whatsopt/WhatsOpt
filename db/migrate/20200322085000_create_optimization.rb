class CreateOptimization < ActiveRecord::Migration[6.0]
  def change
    create_table :optimizations do |t|
      t.string :kind
      t.text :config
      t.text :inputs
      t.text :outputs
      t.timestamps
    end
  end
end
