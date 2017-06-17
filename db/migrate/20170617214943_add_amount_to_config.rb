class AddAmountToConfig < ActiveRecord::Migration[5.0]
  def change
    add_column :configs, :amount, :float, null: false, default: 0.0
  end
end
