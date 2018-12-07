class AddLogCountToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :log_count, :integer, default:0
  end
end
