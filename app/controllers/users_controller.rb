class UsersController < ApplicationController
  before_filter :login_required, :except => :facebook_oauth

  def index
    case params[:rank_by]
      when 'wins'
        case params[:period]
          when 'weekly'
            @send = "games_won_this_week"
          when 'monthly'
            @send = "games_won_this_month"
          else
            @send = "games_won_today"
        end
      else
        @send = "#{params[:period] || 'daily'}_#{params[:rank_by]|| 'rating'}"
    end
    @users = User.top_scorers(@send)
  end

  def show
    @user = User.find_by_id(params[:id]) || current_user
  end
end
