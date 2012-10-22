class GamesController < ApplicationController
  before_filter :login_required
  load_and_authorize_resource

  def index
    @games = @games.active_first.page(params[:page])
  end

  def show

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
    ['rating','precision','wins'].each do |score_by|
      ['daily','weekly','monthly'].each do |period|
        rank_by = "#{period}_#{score_by}"
        ranks[rank_by] = current_user.rank(rank_by)
      end
    end
    @game.save
    if @game.completed?
      current_user.reload
      @notice ||= ""
      ['rating','precision','wins'].each do |score_by|
        ['daily','weekly','monthly'].each do |period|
          rank_by = "#{period}_#{score_by}"
          rank = current_user.rank(rank_by)
          if rank < ranks[rank_by]
            @notice << "#{period} #{score_by}: #{rank.ordinalize}. "
            break
          end
        end
      end
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
