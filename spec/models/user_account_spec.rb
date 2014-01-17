# == Schema Information
#
# Table name: user_accounts
#
#  id            :integer          not null, primary key
#  uid           :string(255)      not null
#  provider      :string(255)      not null
#  real_name     :string(255)
#  mobile_number :string(255)
#  email         :string(255)
#  credits       :integer          default(24)
#  prize_points  :integer
#  lock_version  :integer          default(0), not null
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe UserAccount do
  describe "Validation" do
    it "must start with a default of 24 credits" do
      UserAccount.new.credits.should == 24
    end

    it "must have a provider" do
      UserAccount.new.should have(1).errors_on(:provider)
      UserAccount.new(provider: 'xx').should have(0).errors_on(:provider)
    end

    it "must have a uid" do
      UserAccount.new.should have(1).errors_on(:uid)
      UserAccount.new(uid: 'xx').should have(0).errors_on(:uid)
    end

    it "must have a unique uid per provider" do
      create(:user_account, uid: "xx", provider: "yy")
      UserAccount.new(uid: 'xx', provider: "yy").should have(1).errors_on(:uid)
      UserAccount.new(uid: 'xx', provider: "zz").should have(0).errors_on(:uid)
    end
  end
end
