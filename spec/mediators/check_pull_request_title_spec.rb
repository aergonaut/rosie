require 'rails_helper'

RSpec.describe CheckPullRequestTitle do
  let(:payload) do
    {
      "pull_request" => {
        "title" => title
      }
    }
  end

  let(:job) { CheckPullRequestTitle.new }

  context "when the title does not match the format" do
    let(:title) { "AU-4242 foobar" }

    it "returns a warning" do
      expect(job.perform(payload).count).to eq(1)
    end
  end

  context "when the title does match the format" do
    let(:title) { "CD-4242 123_release foobar" }

    it "does not return any errors" do
      expect(job.perform(payload)).to be_empty
    end
  end
end
