class RenameErrOnMaxiterToErrOnNonConverge < ActiveRecord::Migration[6.0]
  def change
    rename_column :solvers, :err_on_maxiter, :err_on_non_converge
  end
end
