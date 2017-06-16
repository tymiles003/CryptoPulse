class CreateConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :configs do |t|
      t.jsonb :allocation, null: false, default: '{}'

      t.timestamps
    end
  end
end
