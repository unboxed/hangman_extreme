require 'spec_helper'

describe "layouts/_menu" do
  include ViewCapybaraRendered

  before(:each) do
    view.stub!(:mxit_request?).and_return(false)
  end

  it "must build ul menu"  do
    grouped_menu_items = [[[ 'new game', new_game_path, id: 'new_game']]]
    render :partial => "layouts/menu", :locals => {:grouped_menu_items => grouped_menu_items}
    within("ul.nav") do
      rendered.should have_css("a#new_game[href='#{new_game_path}']")
    end
  end

  it "must group 2 links into first li if shorter than 20 characters"  do
    grouped_menu_items = [[['new game', new_game_path, id: 'new_game'],
                           ['buy', purchases_path, id: 'buy']]]
    render :partial => "layouts/menu", :locals => {:grouped_menu_items => grouped_menu_items}
    within("li.item1") do
      rendered.should have_css("a#new_game[href='#{new_game_path}']")
      rendered.should have_css("a#buy[href='#{purchases_path}']")
    end
  end

  it "must work with text markup"  do
    grouped_menu_items = [[['<a id="grant" href="/speelman">Hello</a>']]]
    render :partial => "layouts/menu", :locals => {:grouped_menu_items => grouped_menu_items}
    within("li.item1") do
      rendered.should have_css("a#grant[href='/speelman']")
    end
  end

end