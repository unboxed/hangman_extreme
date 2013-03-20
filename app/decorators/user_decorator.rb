class UserDecorator < Draper::Decorator
  delegate_all

  def daily_random
    wins_required_text(daily_wins_required_for_random)
  end

  def weekly_random
    wins_required_text(weekly_wins_required_for_random)
  end

  def daily_random_rank
    ""
  end

  def weekly_random_rank
    ""
  end

  def method_missing(m, *args, &block)
    if /^(daily|weekly)_(streak|rating|precision)_rank\z/.match(m.to_s)
      rank(m.to_s.gsub("_rank","")).ordinalize
    else
      super(m, *args, &block)
    end
  end

  private

  def wins_required_text(wins_required)
    wins_required > 0 ? "#{h.pluralize(wins_required,"more game")}" : "Entered"
  end

end
