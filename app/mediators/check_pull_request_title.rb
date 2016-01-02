class CheckPullRequestTitle
  def perform(payload)
    title = payload["pull_request"]["title"]
    title_format = /(cd|jz|cm)\-(\d+)\s+(\d{3}_release)\s+(.+)/i
    Array(@warnings) << "Pull Request title does not match the standard format" unless title =~ title_format
  end

  def warnings
    @warnings ||= []
  end
end
