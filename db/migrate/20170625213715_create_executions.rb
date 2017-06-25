class CreateExecutions < ActiveRecord::Migration[5.0]
  def change
    create_table :executions do |t|
      t.references :config, foreign_key: true

      t.timestamps
    end
  end
end
