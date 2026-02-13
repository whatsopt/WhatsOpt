# frozen_string_literal: true

class DropOptimizations < ActiveRecord::Migration[7.0]
  def up
    # Clean up orphaned Rolify roles referencing Optimization
    execute <<-SQL
      DELETE FROM roles WHERE resource_type = 'Optimization'
    SQL
    execute <<-SQL
      DELETE FROM users_roles WHERE role_id NOT IN (SELECT id FROM roles)
    SQL

    drop_table :optimizations
  end

  def down
    create_table :optimizations do |t|
      t.string :kind
      t.text :config, limit: 16.megabytes - 1
      t.text :inputs, limit: 16.megabytes - 1
      t.text :outputs, limit: 16.megabytes - 1
      t.timestamps
    end
  end
end
