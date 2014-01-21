class UserAccountsController < ApplicationController
  before_filter :set_user_account

  def show
  end

  def edit

  end

  def update
    if @user_account.update_attributes(user_params)
      redirect_to user_accounts_path, notice: 'Profile was successfully updated.'
    else
      redirect_to user_accounts_path, alert: @user_account.errors.inspect
    end
  end

  private

  def set_user_account
    @user_account = current_user_account
  end

  def user_params
    params[:user_account].permit(:real_name, :mobile_number)
  end
end
