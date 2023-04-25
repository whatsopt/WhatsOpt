class AddDisciplineIdToFastoadModules < ActiveRecord::Migration[7.0]
  def change
    add_reference :fastoad_modules, :discipline, type: :integer, foreign_key: true
  end
end
