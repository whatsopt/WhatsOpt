class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :status
      t.text :log
      t.integer :pid
      t.integer :operation_id
    end
  end
end
