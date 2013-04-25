class WinnersController < ApplicationController
  load_and_authorize_resource

  def index
    @winners = Winner.scope_for(@winners,params)
  end
end
