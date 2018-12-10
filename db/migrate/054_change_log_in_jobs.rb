class ChangeLogInJobs < ActiveRecord::Migration[5.2]
  def up
    add_column :jobs, :log_count, :integer, default:0
  end
  def down
    remove_column :jobs, :log_count
  end
end
