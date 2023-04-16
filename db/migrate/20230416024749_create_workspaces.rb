class CreateWorkspaces < ActiveRecord::Migration[7.0]
  def change
    create_table :workspaces do |t|
      t.string :access_token, null: false
      t.string :workspace_id, null: false
      t.timestamps
    end
  end
end
