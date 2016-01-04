require 'rails_helper'

RSpec.describe ReceivePullRequestEvent do
  let(:job) { ReceivePullRequestEvent.new }

  let(:payload) do
    from_fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request.json")))
    from_fixture
  end

  let(:fake_subtask) do
    Class.new do
      def self.run(*); end
    end
  end

  before do
    expect(fake_subtask).to receive(:run).and_return(fake_subtask_result)
    expect(ReceivePullRequestEvent).to receive(:subtasks).and_return([fake_subtask])

    stub_request(:post, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/issues/\d+/comments})
  end

  context "when one of the subtasks raises a warning" do
    let(:fake_subtask_result) { ["something happened"] }

    before do
      job.perform(payload)
    end

    it "posts a comment to GitHub" do
      expect(WebMock).to have_requested(:post, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/issues/\d+/comments})
    end
  end

  context "when there are no warnings" do
    let(:fake_subtask_result) { [] }

    before do
      job.perform(payload)
    end

    it "does not post any comments" do
      expect(WebMock).to_not have_requested(:post, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/issues/\d+/comments})
    end
  end
end
