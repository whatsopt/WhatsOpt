class AddPositionToDisciplines < ActiveRecord::Migration[5.1]
  def change
    add_column :disciplines, :position, :integer
  end
end
