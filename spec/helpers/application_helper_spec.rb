require 'spec_helper'

describe ApplicationHelper do

  context "smart_link_to" do

    it "should work like normal link" do
      helper.stub(:mxit_request?).and_return(false)
      helper.smart_link_to('new game', new_game_path, id: 'new_game').should == link_to('new game', new_game_path, id: 'new_game')
    end

    it "should optimize for mxit if mxit request" do
      helper.stub(:mxit_request?).and_return(true)
      helper.smart_link_to('new game', new_game_path, id: 'new_game').should == link_to('new', new_game_path, id: 'new_game') + " game"
    end

  end

end