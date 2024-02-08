class ChangeOptimizationDataLimit < ActiveRecord::Migration[7.1]
  def change
    change_column :optimizations, :inputs, :text, limit: 16.megabytes - 1
    change_column :optimizations, :outputs, :text, limit: 16.megabytes - 1
  end
end
