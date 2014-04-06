require 'spec_helper'

describe UserSendMessage do

  describe 'send_all' do

    before :each do
      MxitApiWrapper.should respond_to(:connect)
      MxitApiWrapper.new(nil).should respond_to(:send_message)
      @mxit_connection = double('Mxit Connection', :send_message => true)
      MxitApiWrapper.stub(:connect).and_return(@mxit_connection)
    end

    it 'must not connect if no users selected' do
      MxitApiWrapper.should_not_receive(:connect)
      UserSendMessage.new('Nobody!!',[]).send_all
    end

    it 'must send a message to a user if mxit user' do
      user = stub_model(User, uid: 'm345', provider: 'mxit')
      @mxit_connection.should_receive(:send_message).once.with(body: 'Single user', to: 'm345')
      UserSendMessage.new('Single user',[user]).send_all
    end

    it 'wont send a message to a user if other user' do
      user = stub_model(User, uid: 'm345', provider: 'other')
      @mxit_connection.should_not_receive(:send_message)
      UserSendMessage.new('Single user',[user]).send_all
    end

    it 'must break up users into groups of 100' do
      @mxit_connection.should_receive(:send_message).twice
      users = create_list(:user, 101)
      UserSendMessage.new('Single user',users).send_all
    end

    it 'must work with relations in groups of 100' do
      @mxit_connection.should_receive(:send_message).twice
      create_list(:user, 101, provider: 'mxit')
      UserSendMessage.new('Single user',User.mxit).send_all
    end

  end

end
