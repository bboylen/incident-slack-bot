class DeclareHandler
  include Shared::SlackClientHandler
  attr :params

  class << self
    def handle_declare(params, command_text)
      new(params).handle_declare(command_text)
    end
  end

  def initialize(params)
    @params = params
  end

  def handle_declare(command_text)
    title, description, severity = parse_declare_arguments(command_text)
  
    begin
      channel = create_slack_channel(title)
    rescue StandardError => e
      return { text: "Error creating Incident slack channel" }
    end

    incident = Incident.create!(title: title, description: description, severity: severity, status: 'open', creator: params[:user_name], slack_channel_id: channel["id"])

    invite_user_to_channel(params[:user_id], channel['id'])
  
    message = "Incident Title: #{incident.title}\nDescription: #{incident.description}\nSeverity: #{incident.severity}"
    slack_client.chat_postMessage(channel: channel['id'], text: message)
  
    { text: "Incident declared successfully! A new channel has been created: ##{channel['name']}" }
  end
  

  private

  def parse_declare_arguments(command_text)
    _, *args = command_text.split

    title = args.shift
    description = args.shift
    severity = args.shift

    [title, description, severity]
  end

  def create_slack_channel(title)
    # handle error if channel name taken
    response = slack_client.conversations_create(name: title.downcase.gsub(' ', '-'))
    if response['ok']
      response['channel']
    else
      raise "Error creating Slack channel: #{response['error']}"
    end
  end

  def invite_user_to_channel(user_id, channel_id)
    slack_client.conversations_invite(channel: channel_id, users: user_id)
  end
end

