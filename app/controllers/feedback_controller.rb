class FeedbackController < ApplicationController
  before_filter :safe_feedback_params, :only => [:new,:create]
  load_and_authorize_resource

  def index
  end

  def new
    @feedback.support_type = params[:type]
  end

  def create
    @feedback.user = current_user
    @feedback.save
    redirect_to(root_path, notice: 'Thank you for your feedback')
  end

  protected

  def safe_feedback_params
    if params[:feedback]
      params[:feedback] = params[:feedback].permit(:full_message, :support_type)
    end
  end

end
