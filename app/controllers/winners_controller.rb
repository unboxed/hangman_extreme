class WinnersController < ApplicationController
  load_and_authorize_resource

  def index
    @winners = scope_for(@winners,params)
  end

  private

  def scope_for(winners,options = {})
    options[:reason] ||= 'rating'
    options[:period] ||= 'daily'
    scope = winners.period(options[:period]).reason(options[:reason]).order('created_at DESC')
    if options[:period] == 'daily'
      scope.yesterday
    else
      scope.last_week
    end
  end

end
