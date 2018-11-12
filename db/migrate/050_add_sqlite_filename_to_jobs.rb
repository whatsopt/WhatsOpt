class AddSqliteFilenameToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :sqlite_filename, :string
  end
end
