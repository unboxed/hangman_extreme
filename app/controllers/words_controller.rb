class WordsController < ApplicationController
  before_filter :login_required
  caches_action :define,  layout: false, expires_in: 7.days

  def define
    @definition = Dictionary.define(params[:word]).join(": ")
  end
end
