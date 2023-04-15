class SlackController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_slack_request

  def rootly
    command_text = params[:text]
    case command_text.split.first
    when 'declare'
      handle_declare(command_text)
    when 'resolve'
      handle_resolve
    else
      render_unknown_command
    end
  end

  private

  def handle_declare(command_text)
    title, description, severity = parse_declare_arguments(command_text)

    # need to add check if channel already exists
    channel = create_slack_channel(title)

    incident = Incident.create(title: title, description: description, severity: severity, status: 'open', creator: params[:user_name], slack_channel_id: channel["id"])

    invite_user_to_channel(params[:user_id], channel['id'])

    message = "Incident Title: #{title}\nDescription: #{description}\nSeverity: #{severity}"
    slack_client.chat_postMessage(channel: channel['id'], text: message)

    render json: {
      text: "Incident declared successfully! A new channel has been created: ##{channel['name']}"
    }
  end

  def handle_resolve
    incident = Incident.find_by(slack_channel_id: params[:channel_id])

    if incident.present? && incident.status == 'open'
      incident.update(status: 'resolved', resolved_at: Time.current)
      time_to_resolution = (incident.resolved_at - incident.created_at).to_i

      render json: {
        text: "Incident resolved successfully! Time to resolution: #{time_to_resolution} seconds."
      }
    else
      render json: {
        text: "Error: This command is only available in open Slack incident channels."
      }
    end
  end

  def parse_declare_arguments(command_text)
    _, *args = command_text.split
    title = args.shift
    description = args.join(' ')
    severity = args.include?('sev0') ? 'sev0' : args.include?('sev1') ? 'sev1' : args.include?('sev2') ? 'sev2' : nil
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
    response = slack_client.conversations_invite(channel: channel_id, users: user_id)
    if response['ok']
      true
    else
      raise "Error inviting user to Slack channel: #{response['error']}"
    end
  end

  def render_unknown_command
    render json: {
      text: "Unknown subcommand. Please use /rootly declare or /rootly resolve."
    }
  end

  def verify_slack_request
    timestamp = request.headers['X-Slack-Request-Timestamp'].to_i
    signature = request.headers['X-Slack-Signature']

    req_body = request.body.read
    request.body.rewind

    basestring = "v0:#{timestamp}:#{req_body}"
    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['SLACK_SIGNING_SECRET'], basestring)
    my_signature = "v0=#{hmac}"

    if !ActiveSupport::SecurityUtils.secure_compare(my_signature, signature)
      render json: { error: 'Invalid request (signature mismatch)' }, status: :unauthorized
    end
  end

  def slack_client
    @slack_client ||= Slack::Web::Client.new
  end
end
