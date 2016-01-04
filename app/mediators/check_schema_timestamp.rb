class CheckSchemaTimestamp
  def self.run(payload)
    new.perform(payload)
  end

  def perform(payload)
    @warnings = []

    github = Octokit::Client.new(access_token: ENV["ROSIE_GITHUB_ACCESS_TOKEN"])
    files = github.pull_request_files(payload["repository"]["full_name"], payload["number"])
    filenames = files.map(&:filename)

    migrations = filenames.select { |filename| filename =~ /db\/migrate\/\d{14}/ }
    if migrations.any?
      migrations.map! do |migration|
        /db\/migrate\/(\d{14})/.match(migration)[1]
      end
      migrations.sort!
      oldest_timestamp = migrations.last

      pr_head_sha = payload["pull_request"]["head"]["sha"]
      schema_contents = github.contents(
        payload["repository"]["full_name"],
        path: "db/schema.rb",
        ref: pr_head_sha
      ).content
      schema_contents = Base64.decode64(schema_contents)

      timestamp_in_schema = %r{ActiveRecord::Schema\.define\(version: (\d+)\)}.match(schema_contents)[1]

      if oldest_timestamp > timestamp_in_schema
        @warnings << "The timestamp in `schema.rb` in this Pull Request is not up to date"
      end
    end

    @warnings
  end
end
