class AuthController < ApplicationController
  def slack_callback
    auth_code = params[:code]

    client = Slack::Web::Client.new

    begin
      response = client.oauth_v2_access(
        client_id: ENV['SLACK_CLIENT_ID'],
        client_secret: ENV['SLACK_CLIENT_SECRET'],
        code: auth_code,
        redirect_uri: "#{request.base_url}/auth/slack/callback"
      )

      if response['ok']
        access_token = response['access_token']
        team_id = response['team']['id']

        workspace = Workspace.find_or_initialize_by(workspace_id: team_id)
        workspace.access_token = access_token
        workspace.save!

        redirect_to root_path
      else
        redirect_to root_path
      end
    rescue Slack::Web::Api::Errors::SlackError => e
      redirect_to root_path
    end
  end
end
