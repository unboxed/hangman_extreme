class ExplainController < ApplicationController
  caches_action :payouts, :precision, :rating, :scoring_categories, :winning_random,
                :winning_streak, expires_in: 7.days

  before_filter :set_as_dialog, :only => [:precision, :rating, :winning_random, :winning_streak]

  protected

  def set_as_dialog
    @dialog = true
  end
end
