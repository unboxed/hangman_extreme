require 'view_spec_helper'

describe 'users/show.html.erb' do

  before(:each) do
    @user = double('User', monthly_score: 'a', monthly_score_rank: 'a')
    Winner.stub(:winning_periods).and_return(['monthly'])
    Winner.stub(:winning_reasons).and_return(['score'])
    view.stub(:menu_item)
  end

  it 'renders a the periods' do
    Winner.should_receive(:winning_periods).and_return(['monthly'])
    render
    rendered.should have_content('Monthly')
  end

  it 'renders the reasons' do
    Winner.should_receive(:winning_reasons).and_return(['score'])
    render
    rendered.should have_content('score')
  end

  it 'must show score and rank' do
    @user.should_receive(:monthly_score).and_return('111')
    @user.should_receive(:monthly_score_rank).and_return('1st')
    render
    rendered.should have_content('111')
    rendered.should have_content('1st')
  end

  it 'should have a leaderboard link on menu' do
    view.should_receive(:menu_item).with(anything,users_path,id: 'leaderboard')
    render
  end

  it 'should have a winners link on menu' do
    view.should_receive(:menu_item).with(anything,winners_path,id: 'winners')
    render
  end

  it 'should have a winners link on menu' do
    view.should_receive(:menu_item).with(anything,explain_path(action: 'scoring_categories'),id: 'scoring_categories')
    render
  end

end
