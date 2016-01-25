require 'rails_helper'

RSpec.describe CheckNewPermissionsIncludeDescriptions do
  let(:payload) do
    {
      "repository" => {
        "full_name" => "aergonaut/testrepo"
      },
      "number" => 42
    }
  end

  let(:pull_request_files_body) { File.open(Rails.root.join("spec", "fixtures", "permission_changes.json")) }

  let(:permissions_yml_contents) do
    encoded_contents = Base64.encode64(YAML.dump(permissions_yml_body))

    from_fixture = JSON.load(File.open(Rails.root.join("spec", "fixtures", "permissions_contents.json")))
    from_fixture["content"] = encoded_contents
    from_fixture["name"] = "permissions.yml"
    from_fixture["path"] = "db/blank/permissions.yml"
    JSON.dump(from_fixture)
  end

  before do
    stub_request(:get, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/pulls/\d+/files}).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: pull_request_files_body
    )

    stub_request(:get, %r{https?://api.github.com/repos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+/contents/db/blank/permissions.yml\?ref=[A-Za-z0-9]{40}}).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: permissions_yml_contents
    )
  end

  let(:job) { CheckNewPermissionsIncludeDescriptions.new }

  describe "#perform" do
    context "when all permissions have blank descriptions" do
      let(:permissions_yml_body) do
        {
          "squiggle_transfers__bulk_loader" => {
            "id" => 4242,
            "controller" => "squiggle_transfers",
            "action" => "bulk_loader",
            "description" => "",
            "flavor" => 4
          },
          "squiggle_transfers__list_csv" => {
            "id" => 4243,
            "controller" => "squiggle_transfers",
            "action" => "list_csv",
            "description" => "",
            "flavor" => 4
          },
          "squiggle_transfers__load_progress" => {
            "id" => 4244,
            "controller" => "squiggle_transfers",
            "action" => "load_progress",
            "description" => "",
            "flavor" => 4
          }
        }
      end

      it "emits 3 warnings" do
        expect(job.perform(payload).count).to eq(3)
      end
    end

    context "when some permissions have blank descriptions" do
      let(:permissions_yml_body) do
        {
          "squiggle_transfers__bulk_loader" => {
            "id" => 4242,
            "controller" => "squiggle_transfers",
            "action" => "bulk_loader",
            "description" => "lorem ipsum",
            "flavor" => 4
          },
          "squiggle_transfers__list_csv" => {
            "id" => 4243,
            "controller" => "squiggle_transfers",
            "action" => "list_csv",
            "description" => "",
            "flavor" => 4
          },
          "squiggle_transfers__load_progress" => {
            "id" => 4244,
            "controller" => "squiggle_transfers",
            "action" => "load_progress",
            "description" => "",
            "flavor" => 4
          }
        }
      end

      it "emits 2 warnings" do
        expect(job.perform(payload).count).to eq(2)
      end
    end

    context "when no permissions have blank descriptions" do
      let(:permissions_yml_body) do
        {
          "squiggle_transfers__bulk_loader" => {
            "id" => 4242,
            "controller" => "squiggle_transfers",
            "action" => "bulk_loader",
            "description" => "lore",
            "flavor" => 4
          },
          "squiggle_transfers__list_csv" => {
            "id" => 4243,
            "controller" => "squiggle_transfers",
            "action" => "list_csv",
            "description" => "ipsum",
            "flavor" => 4
          },
          "squiggle_transfers__load_progress" => {
            "id" => 4244,
            "controller" => "squiggle_transfers",
            "action" => "load_progress",
            "description" => "dolor",
            "flavor" => 4
          }
        }
      end

      it "emits a warning" do
        expect(job.perform(payload)).to be_empty
      end
    end
  end
end
