class AddQualityToSurrogates < ActiveRecord::Migration[6.0]
  def change
    add_column :surrogates, :quality, :text
  end
end
