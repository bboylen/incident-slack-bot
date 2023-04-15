class ResolveHandler
  attr :params

  class << self
    def handle_resolve(params)
      new(params).handle_resolve
    end
  end

  def initialize(params)
    @params = params
  end

  def handle_resolve
    incident = Incident.find_by(slack_channel_id: params[:channel_id])

    if incident.present? && incident.status == 'open'
      incident.update(status: 'resolved', resolved_at: Time.current)
      time_to_resolution = (incident.resolved_at - incident.created_at).to_i

      {
        text: "Incident resolved successfully! Time to resolution: #{time_to_resolution} seconds."
      }
    else
      {
        text: "Error: This command is only available in open Slack incident channels."
      }
    end
  end

  private

  def slack_client
    @slack_client ||= Slack::Web::Client.new
  end
end

