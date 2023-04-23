class AddCustomConfigIdToAnalyses < ActiveRecord::Migration[7.0]
  def change
    add_column :analyses, :custom_config_id, :integer, foreign_key: true
  end
end
