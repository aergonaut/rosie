class CheckNewPermissionsIncludeDescriptions
  def self.run(payload)
    new.perform(payload)
  end

  def perform(payload)
    @warnings = []

    github = Octokit::Client.new(access_token: ENV["ROSIE_GITHUB_ACCESS_TOKEN"])
    files = github.pull_request_files(payload["repository"]["full_name"], payload["number"])

    permission_files = files.select { |file| file.filename =~ /db\/(seed|blank)\/permissions\.yml/ }

    permission_files.each do |perm_file|
      # get the contents of the file at the revision
      contents = Base64.decode64(perm_file.rels[:contents].get.data.content)

      # parse the contents as yml
      parsed = YAML.load(contents)

      patch = perm_file.patch

      # scan the patch for new names
      # names necessarily start with an + followed by letters and a colon, since
      # this indicates top-level elements in a YAML document
      added_permission_names = patch.scan(/^\+([A-Za-z_-]+):/).map(&:first)

      added_permission_names.each do |perm|
        if parsed[perm]["description"].blank?
          @warnings << "Added permission `#{perm}` in `#{perm_file}` has no description"
        end
      end
    end

    @warnings
  end
end
