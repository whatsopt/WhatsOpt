class CreateParameters < ActiveRecord::Migration[5.1]
  def change
    create_table :parameters do |t|
      t.string :init
      t.string :lower
      t.string :upper
      t.integer :variable_id
    end
  end
end
