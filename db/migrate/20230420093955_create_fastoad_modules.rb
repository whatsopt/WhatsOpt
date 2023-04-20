class CreateFastoadModules < ActiveRecord::Migration[7.0]
  def change
    create_table :fastoad_modules do |t|
      t.string :name
      t.string :fastoad_id
      t.string :version
      t.references :fastoad_config, foreign_key: true

      t.timestamps
    end
  end
end
