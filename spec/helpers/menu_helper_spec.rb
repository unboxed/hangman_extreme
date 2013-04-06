require 'spec_helper'

describe MenuHelper do

  context "Menu" do

    before :each do
      view.stub!(:mxit_request?).and_return(true)
    end

    it "must start with empty menu items if not mxit request?" do
      view.stub!(:mxit_request?).and_return(false)
      helper.menu_items.should be_empty
    end

    it "must start with home menu items if mxit request?" do
      helper.menu_items.should include(['home', root_path, id: 'home'])
    end

    it "must add a item to menu items" do
      helper.menu_item 'new game', new_game_path, id: 'new_game'
      helper.menu_items.should include(['new game', new_game_path, {id: 'new_game'}])
    end

    context "grouped_menu_items" do

      context "mobile" do
        before :each do
          helper.stub!(:mxit_request?).and_return(false)
        end

        it "returns links in there own items" do
          new_game_item = ['new game', new_game_path, id: 'new_game']
          buy_item = ['buy', purchases_path, id: 'buy']
          helper.menu_item(*new_game_item)
          helper.menu_item(*buy_item)
          helper.grouped_menu_items.should eq [[new_game_item],[buy_item]]
        end

      end

      context "mxit" do

        before :each do
          helper.stub!(:mxit_request?).and_return(true)
        end

        it "returns 2 links in separate items if they are longer 20 chars" do
          new_game_item = ['new game', new_game_path, id: 'new_game']
          buy_item = ['buy asdasdasdasdasdasd', purchases_path, id: 'buy']
          helper.menu_item(*new_game_item)
          helper.menu_item(*buy_item)
          helper.grouped_menu_items.should include([buy_item])
        end

      end

    end

  end

end