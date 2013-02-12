require 'spec_helper'

describe MenuHelper do

  context "Menu" do

    it "must start with empty menu items" do
      helper.menu_items.should be_empty
    end

    it "must add a item to menu items" do
      helper.menu_item 'new game', new_game_path, id: 'new_game'
      helper.menu_items.should include(['new game', new_game_path, {id: 'new_game'}])
    end

    context "grouped_menu_items" do

      it "returns 2 links into the first item if they are shorter than 20 chars" do
        new_game_item = ['new game', new_game_path, id: 'new_game']
        buy_item = ['buy', purchases_path, id: 'buy']
        helper.menu_item(*new_game_item)
        helper.menu_item(*buy_item)
        helper.grouped_menu_items.should eq [[new_game_item, buy_item]]
      end

      it "returns 2 links in separate items if they are longer 20 chars" do
        new_game_item = ['new game', new_game_path, id: 'new_game']
        buy_item = ['buy asdasdasdasdasdasd', purchases_path, id: 'buy']
        helper.menu_item(*new_game_item)
        helper.menu_item(*buy_item)
        helper.grouped_menu_items.should eq [[new_game_item], [buy_item]]
      end

      it "iterates and groups two items if the length is greater than 20" do
        new_game_item = ['new gameASDasdasDadasD', new_game_path, id: 'new_game']
        buy_item = ['buy', purchases_path, id: 'buy']
        another_buy_item = ['another ', purchases_path, id: 'buy']
        helper.menu_item(*new_game_item)
        helper.menu_item(*buy_item)
        helper.menu_item(*another_buy_item)
        helper.grouped_menu_items.should eq [[new_game_item], [buy_item, another_buy_item]]
      end

    end

    context "menu" do

      def render_menu
        @rendered = helper.menu
      end

      def rendered
        # Using @rendered variable, which is set by the render-method.
        Capybara.string(@rendered)
      end

      def within(selector)
        yield rendered.find(selector)
      end

      it "must build ul menu"  do
        helper.menu_item 'new game', new_game_path, id: 'new_game'
        render_menu
        within("ul.menu") do
          rendered.should have_css("a#new_game[href='#{new_game_path}']")
        end
      end

      it "must group 2 links into first li if shorter than 20 characters"  do
        helper.menu_item 'new game', new_game_path, id: 'new_game'
        helper.menu_item 'buy', purchases_path, id: 'buy'
        render_menu
        within("li.item1") do
          rendered.should have_css("a#new_game[href='#{new_game_path}']")
          rendered.should have_css("a#buy[href='#{purchases_path}']")
        end
      end

    end

  end

end