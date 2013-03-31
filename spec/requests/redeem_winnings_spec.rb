require 'spec_helper'
require "#{Rails.root}/app/jobs/issue_airtime_to_users.rb"

describe 'redeem winnings', :shinka_vcr => true, :redis => true do

  before :each do
    @current_user = create(:user, uid: 'm2604100', provider: 'mxit', prize_points: 100)
    set_mxit_headers('m2604100') # set mxit user
    stub_mxit_oauth
  end

  it "must show users redeem winnings link" do
    stub_mxit_money
    create(:won_game, user: @current_user)
    visit '/'
    click_link('redeem')
    page.should have_content("Redeeming Winnings")
    page.should have_content("100 prize points")
    click_link('root_page')
    page.current_path.should == '/'
  end

  it "must allow to redeem prize points for clues" do
    stub_mxit_money
    @current_user.update_attributes(:prize_points => 57, :clue_points => 10)
    visit '/'
    click_link('redeem')
    page.should have_content("57 prize points")
    click_link('clue_points')
    page.should have_content("10 clue points")
    click_button('redeem')
    page.should have_content("47 prize points")
    click_link('root_page')
    click_link('buy_clue_points')
    page.should have_content("20 clue points")
  end

  it "must allow to redeem prize points for mxit_money" do
    stub_mxit_money(:is_registered => true)
    @current_user.update_attributes(:prize_points => 257)
    visit '/'
    click_link('redeem')
    page.should have_content("257 prize points")
    click_link('mxit_money')
    page.should have_content("R2.57 mxit money")
    click_button('redeem')
    page.should have_content("0 prize points")
  end

  {vodago: [200,500,1000],
   cell_c: [500,1000,2500],
   mtn: [500,1000,1500],
   virgin: [1000,1500,3500],
   heita: [500,1000,2000]}.each do |provider,values|

    values.each do |value|
      it "must allow to redeem prize points for #{provider} R#{value / 100} airtime" do
        VCR.use_cassette("redeem_prize_points#{provider}",
                         :record => :once,
                         :erb => true,
                         :match_requests_on => [:uri,:method]) do
          stub_mxit_money
          @current_user.update_attributes(:prize_points => value + 1)
          visit '/'
          click_link('redeem')
          page.should have_content("#{value + 1} prize points")
          click_link("#{provider}_airtime")
          page.should have_content("R#{value / 100} #{provider.to_s.gsub("_"," ")} airtime")
          click_button('redeem')
          page.should have_content("1 prize points")
          click_link('airtime_vouchers')
          App::Jobs::IssueAirtimeToUsers.new.run
          visit '/'
          click_link('redeem')
          click_link('airtime_vouchers')
          page.should have_content("R#{value / 100}")
        end
      end
    end

  end

end