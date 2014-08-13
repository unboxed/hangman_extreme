class SessionsController < ApplicationController
  def destroy
    self.current_user = nil
    redirect_to '/'
  end

  # if Rails.env.test?
    def create
      self.current_user = User.find_or_create_by(uid: params[:uid], provider: params[:provider])
      redirect_to '/'
    end
  # else
  #
  # end
end

