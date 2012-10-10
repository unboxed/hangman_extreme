class FeedbackController < ApplicationController
  before_filter :login_required

  def index
  end

  def new
  end

  def create
    if params[:feedback].blank?
      redirect_to(root_path)
    else
      body, subject = params[:feedback].split(":",2).reverse
      send_options = {:email => "#{current_user.uid}_#{current_user.provider}@noreply.io",
                            :subject => subject || "Message from #{current_user.real_name}",
                            :message => body}
      if params[:type] == 'suggestion'
        Feedback.send_suggestion(send_options)
      else
        Feedback.send_support(send_options)
      end
      redirect_to(root_path, notice: "Thank you for your feedback")
    end
  end

end
