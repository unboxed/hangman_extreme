module FeedbackHelper
  def feedback_url
    mxit_auth_url(state: 'feedback')
  end
end
