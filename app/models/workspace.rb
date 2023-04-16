class Workspace < ApplicationRecord
  validates :workspace_id, presence: true, uniqueness: true
  validates :access_token, presence: true
end
