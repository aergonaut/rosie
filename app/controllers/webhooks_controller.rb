class WebhooksController < ApplicationController
  def pull_request
    body = JSON.load(request.body)

    if body["action"] == "opened" || body["action"] == "synchronize"
      ReceivePullRequestEvent.perform_async(body.slice("action", "number", "pull_request", "repository"))
    end

    head :accepted
  end
end
