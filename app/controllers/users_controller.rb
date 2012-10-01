class UsersController < ApplicationController
  before_filter :login_required, :except => :facebook_oauth

  def index
    case params[:rank_by]
      when 'wins'
        case params[:period]
          when 'weekly'
            @users = User.top_scorers("games_won_this_week")
          when 'monthly'
            @users = User.top_scorers("games_won_this_month")
          else
            @users = User.top_scorers("games_won_today")
        end
      else
        @users = User.top_scorers("#{params[:period] || 'daily'}_#{params[:rank_by]|| 'rating'}")
    end
  end

  def show
    @user = User.find_by_id(params[:id]) || current_user
  end
end
