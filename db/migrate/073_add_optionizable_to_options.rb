class AddOptionizableToOptions < ActiveRecord::Migration[6.0]
  def change
    add_reference :options, :optionizable, polymorphic: true, index: true
  end
end
