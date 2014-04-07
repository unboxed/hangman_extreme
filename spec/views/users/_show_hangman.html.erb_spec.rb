require 'view_spec_helper'

describe 'users/_show_hangman.html.erb' do

  before(:each) do
    @user = stub_model(User, id: 50)
    view.stub(:current_user).and_return(@user)
  end

  it 'renders no link when show hangman enabled' do
    @user.show_hangman = true
    render
    rendered.should have_link('No')
  end


  it 'wont render yes link when show hangman enabled' do
    @user.show_hangman = true
    render
    rendered.should_not have_link('Yes')
  end

  it 'renders yes link when show hangman disabled' do
    @user.show_hangman = false
    render
    rendered.should have_link('Yes')
  end

  it 'wont render no link when show hangman disabled' do
    @user.show_hangman = false
    render
    rendered.should_not have_link('No')
  end
end
