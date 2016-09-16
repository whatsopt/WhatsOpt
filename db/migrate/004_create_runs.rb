class CreateRuns < ActiveRecord::Migration[5.0]
  def change
    create_table :runs do |t|
      t.integer :study_id

      t.timestamps
    end
  end
end
