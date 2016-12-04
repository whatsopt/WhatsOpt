class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.references :container, :polymorphic => true

      t.attachment :data
      t.string :description
      t.timestamps
    end
  end
end
