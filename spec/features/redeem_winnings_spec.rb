require 'spec_helper'

shared_examples "a winner redeemer" do

  it "must show users redeem winnings link" do
    @current_user.update_attributes(:prize_points => 100)
    visit_home
    click_link('redeem')
    page.should have_content("Redeeming Winnings")
    page.should have_content("100 prize points")
    click_link('Home')
    page.current_path.should == '/'
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
          @current_user.update_attributes(:prize_points => value + 1)
          visit_home
          click_link('redeem')
          page.should have_content("#{value + 1} prize points")
          click_link("#{provider}_airtime")
          page.should have_content("R#{value / 100} #{provider.to_s.gsub("_"," ")} airtime")
          click_button('redeem')
          page.should have_content("1 prize points")
          click_link('airtime_vouchers')
          page.should have_content('Airtime Vouchers')
          page.should have_no_content("R#{value / 100}")
          IssueAirtimeToUsers.drain
          visit_home
          click_link('redeem')
          click_link('airtime_vouchers')
          page.should have_content("R#{value / 100}")
        end
      end
    end

  end

end

describe 'redeem winnings', :redis => true do

  context "as mxit user", :google_analytics_vcr => true do

    before :each do
      @current_user = mxit_user('m2604100')
      set_mxit_headers('m2604100') # set mxit user
      stub_mxit_oauth
      stub_mxit_money(:is_registered => true)
    end

    it_behaves_like "a winner redeemer"

    it "must allow to redeem prize points for mxit_money" do
      @current_user.update_attributes(:prize_points => 257)
      visit_home
      click_link('redeem')
      page.should have_content("257 prize points")
      click_link('mxit_money')
      page.should have_content("R2.57 mxit money")
      click_button('redeem')
      page.should have_content("0 prize points")
    end

  end

  context "as mobile user",:facebook => true, :smaato_vcr => true, :js => true do

    before :each do
      @current_user = facebook_user
      login_facebook_user(@current_user)
    end

    it_behaves_like "a winner redeemer"

  end

  context "as guest user", :smaato_vcr => true, :js => true do

    it "must show users redeem winnings link" do
      visit_home
      click_link('redeem')
      page.should have_content("Redeeming Winnings")
      click_link('Home')
      page.current_path.should == '/'
    end

  end

end
