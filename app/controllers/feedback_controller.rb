class FeedbackController < ApplicationController
  skip_filter :check_server_status, :only => 'server_status'
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
      send_options = {:email => current_user.email,
                      :subject => subject || body[0,30],
                      :message => body,
                      :name => current_user.real_name || CGI::unescape(current_user.name).gsub(/[^a-zA-Z0-9\s]/,"")}
      begin
        if params[:type] == 'suggestion'
          Feedback.send_suggestion(send_options)
        else
          Feedback.send_support(send_options)
        end
      rescue Exception => e
        ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
        raise if Rails.env.test?
      end
      redirect_to(root_path, notice: "Thank you for your feedback")
    end
  end

end
