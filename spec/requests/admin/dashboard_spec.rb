require 'spec_helper'

describe 'dashboard' do

  it "must show stats" do
    stub_mxit_oauth
    MxitApiWrapper.any_instance.stub(:send_message).and_return(true)
    users = create_list(:user,5, prize_points: 14)
    users.each do |user|
      14.times do |i|
        Timecop.freeze(i.days.ago) do
          create_list(:won_game,2, user: user)
          create(:purchase_transaction, user: user)
          create(:redeem_winning, user: user)
        end
      end
    end
    Winner.create_daily_winners
    visit_and_login '/admin'
    page.should have_css("div#chart")
  end

end