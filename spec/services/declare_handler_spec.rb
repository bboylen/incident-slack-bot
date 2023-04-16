require 'rails_helper'

RSpec.describe DeclareHandler, type: :service do
  let(:workspace) { FactoryBot.create(:workspace) }
  let(:params) { { user_name: 'test_user', user_id: 'U12345678', team_id: workspace.workspace_id } }
  let(:command_text) { 'declare Test Incident test description sev1' }

  describe '.handle_declare' do
    context "when everything everything is valid" do
      before do
        # Stub the Slack API calls
        allow_any_instance_of(Slack::Web::Client).to receive(:conversations_create).and_return({
          'ok' => true,
          'channel' => { 'id' => 'C12345678', 'name' => 'test-incident' }
        })
  
        allow_any_instance_of(Slack::Web::Client).to receive(:conversations_invite).and_return({
          'ok' => true
        })
  
        allow_any_instance_of(Slack::Web::Client).to receive(:chat_postMessage).and_return({
          'ok' => true
        })
      end
  
      it 'creates an incident and returns a success message' do
        expect(Incident.count).to eq(0)
        result = DeclareHandler.handle_declare(params, command_text)
        expect(result[:text]).to include('Incident declared successfully!')
        expect(Incident.count).to eq(1)
      end
    end
    
    context "when channel creation fails" do
      before do
        allow_any_instance_of(Slack::Web::Client).to receive(:conversations_create).and_return({ 'ok' => false, 'error' => 'channel_creation_failed' })
      end

      it "returns an error message" do
        response = DeclareHandler.handle_declare(params, command_text)
        expect(response).to eq({ text: "Error creating Incident slack channel" })
      end

      it "does not create an incident" do
        expect { DeclareHandler.handle_declare(params, command_text) }.not_to change { Incident.count }
      end
    end
  end
end
