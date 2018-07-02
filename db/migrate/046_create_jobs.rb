class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :status
      t.text :log, default: ""
      t.integer :pid, default: -1
      t.integer :operation_id
      t.datetime :started_at
      t.datetime :ended_at 
    end
  end
end
