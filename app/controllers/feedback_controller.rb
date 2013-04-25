class FeedbackController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def new
    @feedback.support_type = params[:type]
  end

  def create
    @feedback.user = current_user
    @feedback.save
    redirect_to(root_path, notice: "Thank you for your feedback")
  end

end
