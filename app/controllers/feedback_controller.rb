class FeedbackController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource except: 'play'

  def index
  end

  def new
  end

  def create
    if params[:feedback].blank?
      redirect_to(root_path, notice: "Thank you for your feedback")
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
        if Rails.env.test?
          puts e.message
          raise
        end
      end
      redirect_to(root_path, notice: "Thank you for your feedback")
    end
  end

end
