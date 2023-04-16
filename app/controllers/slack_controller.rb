class SlackController < ApplicationController
  # include SlackClientHandler

  skip_before_action :verify_authenticity_token
  before_action :verify_slack_request, only: [:rootly]
  # before_action :set_slack_client, only: [:rootly]


  def rootly
    command_text = params[:text]
    case command_text.split.first
    when 'declare'
      response_payload = DeclareHandler.handle_declare(params, command_text)
    when 'resolve'
      response_payload = ResolveHandler.handle_resolve(params)
    else
      response_payload = unknown_command_response_payload
    end
    render json: response_payload
  end

  private

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
end
