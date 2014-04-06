# encoding: utf-8
require 'features_helper'

shared_examples 'a user geek' do

  it 'must allow to look up definition of the word' do
    body = [{'text' => 'today is tomorrow'}].to_json
    stub_request(:get, 'http://api.wordnik.com/v4/word.json/today/definitions').
      to_return(:status => 200, :body => body, :headers => {})
    create(:won_game, word: 'today', user: @current_user)
    visit '/'
    click_link 'show'
    click_link 'define_word'
    page.should have_content('Defining: today')
    page.should have_content('today is tomorrow')
  end

end

describe 'users', :redis => true do

  context 'as mxit user', :google_analytics_vcr => true do

    before :each do
      @current_user = mxit_user('m2604100')
      set_mxit_headers('m2604100') # set mxit user
    end

    it_behaves_like 'a user geek'

  end

  context 'as mobile user', :facebook => true, :smaato_vcr => true, :js => true do

    before :each do
      @current_user = facebook_user
      login_facebook_user(@current_user)
    end

    it_behaves_like 'a user geek'

  end

  # can't play games
  context 'as guest user', :smaato_vcr => true, :js => true do

  end

end
