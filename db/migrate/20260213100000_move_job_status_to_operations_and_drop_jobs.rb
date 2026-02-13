# frozen_string_literal: true

class MoveJobStatusToOperationsAndDropJobs < ActiveRecord::Migration[7.0]
  def up
    # Add status column to operations (absorbing from jobs)
    add_column :operations, :status, :string, default: "DONE_OFFLINE"

    # Migrate status data from jobs to operations
    execute <<-SQL
      UPDATE operations
      SET status = (SELECT jobs.status FROM jobs WHERE jobs.operation_id = operations.id)
    SQL

    # Remove host column (remote-only)
    remove_column :operations, :host

    # Drop jobs table
    drop_table :jobs, if_exists: true
  end

  def down
    add_column :operations, :host, :string, default: ""

    create_table :jobs do |t|
      t.datetime :ended_at, precision: nil
      t.text :log
      t.integer :log_count, default: 0
      t.integer :operation_id
      t.integer :pid, default: -1
      t.string :sqlite_filename
      t.datetime :started_at, precision: nil
      t.string :status
    end

    # Move status back to jobs
    execute <<-SQL
      INSERT INTO jobs (operation_id, status)
      SELECT id, status FROM operations
    SQL

    remove_column :operations, :status
  end
end
