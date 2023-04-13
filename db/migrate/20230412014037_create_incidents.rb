class CreateIncidents < ActiveRecord::Migration[7.0]
  def change
    create_table :incidents do |t|
      t.string :title, null: false
      t.string :description
      t.string :creator, null: false
      t.string :status, null: false
      t.string :slack_channel_id, null: false
      t.string :severity
      t.datetime :resolved_at
      t.timestamps
    end
  end
end
