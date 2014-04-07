# == Schema Information
#
# Table name: user_accounts
#
#  id            :integer          not null, primary key
#  uid           :string(255)      not null
#  provider      :string(255)      not null
#  mxit_login    :string(255)
#  real_name     :string(255)
#  mobile_number :string(255)
#  email         :string(255)
#  credits       :integer          default(24)
#  prize_points  :integer          default(0)
#  lock_version  :integer          default(0), not null
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe UserAccount do
  describe 'Validation' do
    it 'must have a provider' do
      UserAccount.new.should have(1).errors_on(:provider)
      UserAccount.new(provider: 'xx').should have(0).errors_on(:provider)
    end

    it 'must have a uid' do
      UserAccount.new.should have(1).errors_on(:uid)
      UserAccount.new(uid: 'xx').should have(0).errors_on(:uid)
    end
  end

  describe 'use_credit' do
    it 'must decrease credits by 1' do
      user_account = UserAccount.new(uid: 'm111', credits: 20)
      user_account.should_receive(:save)
      user_account.use_credit!
      user_account.credits.should be == 19
    end

    it 'will raise an error if 0 credits' do
      user_account = UserAccount.new(uid: 'm111', credits: 0)
      expect{ user_account.use_credit!}.to raise_error
      user_account.credits.should be == 0
    end
  end

  describe 'registered_on_mxit_money?' do
    before :each do
      @mxit_money_connection = double('connection', :user_info => {:is_registered => false})
      MxitMoneyApi.stub(:connect).and_return(@mxit_money_connection)
      @user_account = UserAccount.new(uid: 'm111')
    end

    it 'must connect to MxitMoneyApi' do
      MxitMoneyApi.should_receive(:connect).with(ENV['MXIT_MONEY_API_KEY']).and_return(@mxit_money_connection)
      @user_account.registered_on_mxit_money?
    end

    it 'must check the user_info with uid' do
      @mxit_money_connection.should_receive(:user_info).with(:id => 'm111').and_return({})
      @user_account.registered_on_mxit_money?
    end

    it 'wont be registered on mxit money if is_registered is false' do
      @user_account.should_not be_registered_on_mxit_money
    end
  end
end
