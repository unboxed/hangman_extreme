class SessionsController < ApplicationController
  def destroy
    self.current_user = nil
    redirect_to '/'
  end

  if Rails.env.test?
    def create
      self.current_user = User.find_or_create_by(uid: params[:uid], provider: params[:provider])
      redirect_to '/'
    end
  else
    def create
      if params[:code]
        mxit_connection = MxitApiWrapper.connect(:grant_type => 'authorization_code',
                                                 :code => params[:code],
                                                 :redirect_uri => create_session_url)
        self.current_user = User.find_or_create_by(uid: mxit_connection.user_id, provider: 'mxit')
        redirect_to '/'
      else
        redirect_to root_path, alert: "#{params[:error]}: #{params[:error_description]}"
      end
    end
  end
end

