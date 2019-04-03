class CreateSolvers < ActiveRecord::Migration[5.2]
  def change
    create_table :solvers do |t|
      t.string :name
      t.float :atol
      t.float :rtol
      t.integer :maxiter
      t.integer :iprint
      t.boolean :err_on_maxiter
    end
  end
end
