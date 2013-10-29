require 'features_helper'

describe 'jobs' do

  it "must update user credits" do
    create(:user, :credits => 0)
    Jobs::SetUserCredits.execute
  end

end
