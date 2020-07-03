class CreateDesignProject < ActiveRecord::Migration[6.0]
  def change
    create_table :design_projects do |t|
      t.string :name
      t.text :description
      t.timestamps
    end
  end
end
