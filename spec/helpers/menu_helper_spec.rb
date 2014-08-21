require 'spec_helper'

describe MenuHelper do
  context 'Menu' do
    it 'must start with home menu items' do
      helper.menu_items.should include(['Home', root_path, id: 'home'])
    end

    it 'must add a item to menu items' do
      helper.menu_item 'new game', new_game_path, id: 'new_game'
      helper.menu_items.should include(['new game', new_game_path, {id: 'new_game'}])
    end

    context 'grouped_menu_items' do
      context 'mxit' do
        it 'returns 2 links in separate items if they are longer 20 chars' do
          new_game_item = ['new game', new_game_path, id: 'new_game']
          buy_item = ['buy asdasdasdasdasdasd', root_path, id: 'buy']
          helper.menu_item(*new_game_item)
          helper.menu_item(*buy_item)
          helper.grouped_menu_items.should include([buy_item])
        end
      end
    end
  end
end
