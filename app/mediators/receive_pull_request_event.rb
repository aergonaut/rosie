class ReceivePullRequestEvent
  include Sidekiq::Worker

  def self.subtasks
    [CheckPullRequestTitle, CheckSchemaTimestamp]
  end

  def perform(payload)
    warns = []

    ReceivePullRequestEvent.subtasks.each do |subtask|
      warnings = subtask.run(payload)
      warns.concat(warnings)
    end

    if warns.any?
      warnings = ""
      warns.each do |w|
        warnings << "* #{w}\n"
      end

      github = Octokit::Client.new(access_token: ENV["ROSIE_GITHUB_ACCESS_TOKEN"])

      comment = <<-EOT
There were the following issues with your Pull Request:

#{warnings}

PR analysis provided by Rosie the Robot Maid.
EOT

      github.add_comment(
        payload["repository"]["full_name"],
        payload["number"],
        comment
      )
    end
  end
end
