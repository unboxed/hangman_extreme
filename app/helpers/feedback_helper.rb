module FeedbackHelper
  def feedback_url
    if mxit_request?
      mxit_auth_url(state: 'feedback')
    else
      feedback_index_path
    end
  end
end
