require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe "POST pull_request" do
    let(:payload) do
      from_fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request.json")))
      from_fixture["action"] = action
      from_fixture
    end

    context "when the action is \"opened\"" do
      let(:action) { "opened" }

      it "creates a ReceivePullRequestEvent job" do
        expect { post :pull_request, JSON.dump(payload) }.to change(ReceivePullRequestEvent.jobs, :size).by(1)
      end
    end
  end
end
