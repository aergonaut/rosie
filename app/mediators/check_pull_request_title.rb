class CheckPullRequestTitle
  def self.run(payload)
    new.perform(payload)
  end

  def perform(payload)
    @warnings = []

    title = payload["pull_request"]["title"]
    title_format = /(cd|jz|cm)\-(\d+)\s+(cd|jz|cm)\-(\d+)\s+(\d{3}_release)\s+(.+)/i
    @warnings << "Pull Request title does not match the standard format" unless title =~ title_format

    @warnings
  end
end
