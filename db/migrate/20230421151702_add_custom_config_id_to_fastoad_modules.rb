class AddCustomConfigIdToFastoadModules < ActiveRecord::Migration[7.0]
  def change
    add_reference :fastoad_modules, :custom_config, foreign_key: { to_table: :fastoad_configs }
  end
end
