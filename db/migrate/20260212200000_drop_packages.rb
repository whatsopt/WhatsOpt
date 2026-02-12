# frozen_string_literal: true

class DropPackages < ActiveRecord::Migration[7.0]
  def up
    drop_table :packages, if_exists: true
  end

  def down
    create_table :packages do |t|
      t.references :analysis, null: false, foreign_key: true
      t.text :description
      t.timestamps
    end
  end
end
