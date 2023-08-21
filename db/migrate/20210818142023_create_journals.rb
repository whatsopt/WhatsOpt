# frozen_string_literal: true

class CreateJournals < ActiveRecord::Migration[6.1]
  def change
    create_table :journals do |t|
      t.column "analysis_id", :integer, default: 0, null: false
      t.column "user_id", :integer, default: 0, null: false
      t.column "created_on", :datetime, null: false
    end

    add_index :journals, :analysis_id
    add_index :journals, :user_id

    create_table :journal_details do |t|
      t.column "journal_id", :integer, default: 0, null: false
      t.column "entity_type", :string, limit: 30, default: "", null: false
      t.column "entity_name", :string, limit: 30, default: "", null: false
      t.column "entity_attr", :string, limit: 30, default: "", null: false
      t.column "action", :string, limit: 30, default: "", null: false
      t.column "old_value", :string
      t.column "value", :string
    end

    add_index :journal_details, :journal_id
  end
end
