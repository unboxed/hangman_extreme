require 'spec_helper'

describe ApplicationHelper do
  context 'smart_link_to' do
    it 'should optimize for mxit if mxit request' do
      helper.smart_link_to('new game', new_game_path, id: 'new_game').should be ==
          link_to('new', new_game_path, id: 'new_game') + ' game'
    end
  end
end
