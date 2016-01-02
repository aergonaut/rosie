require 'rails_helper'

RSpec.describe ReceivePullRequestEvent do
  let(:job) { ReceivePullRequestEvent.new }

  let(:payload) do
    from_fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request.json")))
    from_fixture
  end

  before do
    stub_request(:post, %r{https?://api.github.com/repos/\w+/\w+/issues/\d+/comments})
  end

  context "when one of the subtasks raises a warning" do
    before do
      expect(CheckPullRequestTitle).to receive(:run).and_return(["something happened"])
      job.perform(payload)
    end

    it "posts a comment to GitHub" do
      expect(WebMock).to have_requested(:post, %r{https?://api.github.com/repos/\w+/\w+/issues/\d+/comments})
    end
  end

  context "when there are no warnings" do
    before do
      expect(CheckPullRequestTitle).to receive(:run).and_return([])
      job.perform(payload)
    end

    it "does not post any comments" do
      expect(WebMock).to_not have_requested(:post, %r{https?://api.github.com/repos/\w+/\w+/issues/\d+/comments})
    end
  end
end
