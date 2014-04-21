class GamesController < ApplicationController
  before_filter :login_required, :except => ['index']
  before_filter :check_credits, :only => ['new', 'create', 'show_clue', 'reveal_clue']
  load_and_authorize_resource except: 'play'

  def index
    @current_game = current_user.current_game
    @games = @games.completed.active_first.limit(1)
  end

  def show

  end

  def play
    redirect_to(current_user.current_game || new_game_path)
  end

  def show_clue

  end

  def reveal_clue
    @game.reveal_clue(current_user.account)
    play
  end

  def time_tracker
    Time.current - @game.created_at
  end

  def play_letter
    ranks = {}
    if @game.possible_last_guess?
      User.scoring_fields.each do |rank_by|
        ranks[rank_by] = current_user.rank(rank_by)
      end
    end
    @game.add_choice(params[:letter])
    @game.save
    if @game.completed?
      current_user.reload
      @notice ||= ''
      unless ranks.empty?
        User.scoring_fields.each do |rank_by|
          rank = current_user.rank(rank_by)
          @notice << "#{rank_by.gsub('_', ' ')}: #{rank.ordinalize}. " if rank < ranks[rank_by]
        end
      end
      if @game.word.length >= 10 && current_user.badges.where(name: 'Bookworm').count == 0 && @game.clue_revealed == false
        current_user.badges.create(name: 'Bookworm')
        @notice << "<br/>Congratulations you have received the #{view_context.link_to 'Bookworm', explain_path(action: 'bookworm', id: 'bookworm')} Badge"
      end
      if current_user.has_five_game_clues_in_sequence && current_user.badges.where(name: 'Clueless').count == 0
        current_user.badges.create(name: 'Clueless')
        @notice << "<br/>Congratulations you have received the #{view_context.link_to 'Clueless', explain_path(action: 'clueless', id: 'clueless')} Badge"
      end
      if time_tracker <= 30 && current_user.badges.where(name: 'Quickster').count == 0 && @game.clue_revealed == false
        current_user.badges.create(name: 'Quickster')
        @notice << "<br/>Congratulations you have received the #{view_context.link_to 'Quickster', explain_path(action: 'quickster', id: 'quickster')} Badge"
      end
      if current_user.has_ten_games_in_sequence && current_user.badges.where(name: 'Brainey').count == 0 && @game.clue_revealed == false
        current_user.badges.create(name: 'Brainey')
        @notice << "<br/>Congratulations you have received the #{view_context.link_to 'Brainey', explain_path(action: 'brainey', id: 'brainey')} Badge"
      end
    end
    redirect_to @game, notice: @notice.to_s.html_safe
  end

  def new

  end

  def create
    @game.user = current_user
    @game.select_random_word
    if @game.word == 'missing'
      e = Exception.new('Dictionary not loaded')
      ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
    end
    if @game.save
      current_user.account.use_credit!
      redirect_to @game, notice: 'Game was successfully created.'
    else
      redirect_to({action: 'index'}, alert: 'Failed to create new game.')
    end
  end

  private

  def check_credits
    if current_user.account_credits > 0
      true
    else
      redirect_to root_path, alert: 'No more credits points left'
      false
    end
  end

end
