# frozen_string_literal: true

class IncreaseJournalDetailsNameSize < ActiveRecord::Migration[6.1]
  def up
    change_column :journal_details, :entity_name, :string, limit: 255
  end

  def down
    change_column :journal_details, :entity_name, :string, limit: 30
  end
end
