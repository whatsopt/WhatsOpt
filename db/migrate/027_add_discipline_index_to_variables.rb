class AddDisciplineIndexToVariables < ActiveRecord::Migration[5.1]
  def change
    add_index :variables, :discipline_id
  end
end
