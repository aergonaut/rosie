require 'rails_helper'

RSpec.describe CheckSchemaTimestamp do
  let(:payload) do
    {
      "number" => "42",
      "pull_request" => {
        "head" => {
          "sha" => "abc123"
        }
      },
      "repository" => {
        "full_name" => "aergonaut/testrepo"
      }
    }
  end

  let(:job) { CheckSchemaTimestamp.new }

  let(:schema_contents_body) do
    fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "schema_contents.json")))
    # byebug
    contents = Base64.decode64(fixture["content"])
    contents.gsub!(/version: \d{14}/, "version: #{schema_timestamp}")
    contents = Base64.encode64(contents)

    fixture["content"] = contents
    JSON.dump(fixture)
  end

  let(:pull_request_files_body) do
    fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "pull_request_files.json")))

    migration_name = "db/migrate/#{migration_timestamp}_foobar.rb"
    fixture[0]["filename"] = migration_name
    JSON.dump(fixture)
  end

  before do
    stub_request(:get, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/contents/.+}).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: schema_contents_body
    )
    stub_request(:get, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+/files}).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: pull_request_files_body
    )
  end

  describe "#perform" do
    context "when the schema is not up to date" do
      let(:schema_timestamp) { Time.now.strftime "%Y%m%d%H%M%S" }

      let(:migration_timestamp) { 2.days.from_now.strftime "%Y%m%d%H%M%S" }

      it "emits a warning" do
        expect(job.perform(payload).count).to eq(1)
      end
    end

    context "when the schema is up to date" do
      let(:schema_timestamp) { Time.now.strftime "%Y%m%d%H%M%S" }

      let(:migration_timestamp) { 2.days.ago.strftime "%Y%m%d%H%M%S" }

      it "does not emit a warning" do
        expect(job.perform(payload)).to be_empty
      end
    end
  end
end
