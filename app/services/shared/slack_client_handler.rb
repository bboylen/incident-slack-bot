module Shared
  module SlackClientHandler
    def slack_client
      @slack_client ||= set_slack_client
    end

    def set_slack_client
      workspace_id = @params[:team_id]
      workspace = Workspace.find_by(workspace_id: workspace_id)

      if workspace
        @slack_client = Slack::Web::Client.new(token: workspace.access_token)
      else
        { error: 'Workspace not authorized' }
      end
    end
  end
end