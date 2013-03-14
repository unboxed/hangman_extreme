class GamesController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource except: 'play'

  def index
    @current_game = current_user.current_game
    @games = @games.completed.active_first.page(params[:page]).per(1)
  end

  def show

  end

  def play
    redirect_to(current_user.current_game || new_game_path)
  end

  def play_letter
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
    ranks = {}
    User::RANKING_FIELDS.each do |rank_by|
      ranks[rank_by] = current_user.rank(rank_by)
    end
    @game.save
    if @game.completed?
      current_user.reload
      @notice ||= ""
      User::RANKING_FIELDS.each do |rank_by|
        rank = current_user.rank(rank_by)
        @notice << "#{rank_by.gsub("_"," ")}: #{rank.ordinalize}. "  if rank < ranks[rank_by]
      end
    end
    redirect_to @game, notice: @notice
  end

  def new

  end

  def create
    @game.user = current_user
    @game.select_random_word
    if @game.word == 'missing'
      e = Exception.new("Dictionary not loaded")
      ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
    end
    if @game.save
      redirect_to @game, notice: 'Game was successfully created.'
    else
      redirect_to({action: 'index'}, alert: 'Failed to create new game.')
    end
  end

end
