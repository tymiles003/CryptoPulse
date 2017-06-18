class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :uuid, null: false

      t.timestamps
    end
  end
end
