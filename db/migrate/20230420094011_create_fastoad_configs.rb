class CreateFastoadConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :fastoad_configs do |t|
      t.string :name
      t.string :version
      t.string :module_folders
      t.string :input_file
      t.string :output_file
      t.references :analysis, type: :integer, foreign_key: true

      t.timestamps
    end
  end
end
