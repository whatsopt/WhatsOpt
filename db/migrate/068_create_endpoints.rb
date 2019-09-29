class CreateEndpoints < ActiveRecord::Migration[6.0]
  def change
    create_table :endpoints do |t|
      t.string :host
      t.integer :port
      t.references :service, polymorphic: true
    end
  end
end
