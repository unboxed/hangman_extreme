class GamesController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource

  def index
    @games = @games.active_first.page(params[:page])
  end

  def show

  end

  def play_letter
    daily_rating, week_rating, monthly_rating = @game.user.daily_rating, @game.user.weekly_rating, @game.user.monthly_rating
    if params[:letter] == 'show_clue'
      if current_user.clue_points < 1
        redirect_to  purchases_path, alert: "No more clue points left"
        return
      end
      @game.reveal_clue
      @notice = "Clue revealed"
    else
      @game.add_choice(params[:letter])
    end
    @game.save
    if daily_rating < @game.user.daily_rating
      @notice = "Your daily rating has increased to #{@game.user.daily_rating}, you are ranked #{@game.user.rank(:daily_rating).ordinalize} today"
    elsif week_rating < @game.user.weekly_rating
      @notice = "Your weekly rating has increased to #{@game.user.weekly_rating}, you are ranked #{@game.user.rank(:weekly_rating).ordinalize} this week"
    elsif monthly_rating < @game.user.monthly_rating
      @notice = "Your monthly rating has increased to #{@game.user.monthly_rating}, you are ranked #{@game.user.rank(:monthly_rating).ordinalize} this month"
    end
    redirect_to @game, notice: @notice
  end

  def new

  end

  def create
    @game.user = current_user
    @game.select_random_word
    if @game.save
      redirect_to @game, notice: 'Game was successfully created.'
    else
      redirect_to({action: 'index'}, alert: 'Failed to create new game.')
    end
  end

end
