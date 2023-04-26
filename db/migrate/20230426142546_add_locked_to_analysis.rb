class AddLockedToAnalysis < ActiveRecord::Migration[7.0]
  def change
    add_column :analyses, :locked, :boolean, default: false
  end
end
