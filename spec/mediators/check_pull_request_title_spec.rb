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

    it "adds a warning to the warnings list" do
      expect { job.perform(payload) }.to change(job.warnings, :count).by(1)
    end
  end

  context "when the title does match the format" do
    let(:title) { "CD-4242 123_release foobar" }

    it "does not have any errors" do
      job.perform(payload)
      expect(job.warnings).to be_empty
    end
  end
end
