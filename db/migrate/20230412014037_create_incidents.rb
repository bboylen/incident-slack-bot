class CreateIncidents < ActiveRecord::Migration[7.0]
  def change
    create_table :incidents do |t|
      t.string :title, null: false
      t.string :description
      t.string :creator, null: false
      t.integer :severity
      t.timestamps
    end
  end
end
