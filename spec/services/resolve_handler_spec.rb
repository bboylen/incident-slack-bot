require 'rails_helper'

RSpec.describe ResolveHandler, type: :service do
  let!(:incident) { FactoryBot.create(:incident, status: 'open', slack_channel_id: 'C12345678') }
  let(:params) { { channel_id: incident.slack_channel_id } }

  describe '.handle_resolve' do
    it 'resolves an incident and returns a success message' do
      result = ResolveHandler.handle_resolve(params)
      expect(result[:text]).to include('Incident resolved successfully!')
      expect(incident.reload.status).to eq('resolved')
    end

    context 'when incident is not open' do
      before do
        incident.update(status: 'resolved')
      end

      it 'returns an error message' do
        result = ResolveHandler.handle_resolve(params)
        expect(result[:text]).to include('Error: This command is only available in open Slack incident channels.')
      end
    end

    context 'when incident is not found' do
      let(:params) { { channel_id: 'C00000000' } }

      it 'returns an error message' do
        result = ResolveHandler.handle_resolve(params)
        expect(result[:text]).to include('Error: This command is only available in open Slack incident channels.')
      end
    end
  end
end
