class AddExecutionToOrders < ActiveRecord::Migration[5.0]
  def change
    add_reference :orders, :execution, foreign_key: true
  end
end
