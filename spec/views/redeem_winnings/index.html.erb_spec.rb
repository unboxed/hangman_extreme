require 'spec_helper'

describe "redeem_winnings/index.html.erb" do

  before(:each) do
    @current_user = stub_model(User, id: 50, registered_on_mxit_money?: false)
    view.stub!(:current_user).and_return(@current_user)
    view.stub!(:menu_item)
  end

  it "should have a home page link on menu" do
    view.should_receive(:menu_item).with(anything,'/',id: 'root_page')
    render
  end

  it "should have a airtime vouchers link on menu" do
    view.should_receive(:menu_item).with(anything,airtime_vouchers_path,id: 'airtime_vouchers')
    render
  end

  it "should have a view rank link on menu" do
    view.should_receive(:menu_item).with(anything,user_path(50),id: 'view_rank')
    render
  end

  it "should have a home page link on menu" do
    view.should_receive(:menu_item).with(anything,'/',id: 'root_page')
    render
  end

  context "clue points" do

    it "must have equal clue points available to prize points" do
      @current_user.prize_points = 5
      render
      rendered.should have_content("#{@current_user.prize_points} clue points")
    end

    it "must have a maximum of 10 clue points available" do
      @current_user.prize_points = 15
      render
      rendered.should have_content("10 clue points")
    end

    it "must have a clue points link" do
      @current_user.prize_points = 5
      render
      rendered.should have_link("clue_points", href: new_redeem_winning_path(:prize_type => 'clue_points',
                                                                             :prize_amount => 5))
    end

    it "wont have a clue points link if no prize points" do
      @current_user.prize_points = 0
      render
      rendered.should_not have_link("clue_points")
    end

  end

  context "mxit money" do

    before :each do
      @current_user.stub(:registered_on_mxit_money?).and_return(true)
    end

    it "must have equal mxit available to prize points" do
      @current_user.prize_points = 1
      render
      rendered.should have_content("R0.0#{@current_user.prize_points} mxit money")
    end

    it "must have a mxit money link" do
      @current_user.prize_points = 51
      render
      rendered.should have_link("mxit_money", href: new_redeem_winning_path(:prize_type => 'mxit_money',
                                                                            :prize_amount => 51))
    end

    it "wont have a mxit_money link if not enough prize points" do
      @current_user.prize_points = 0
      render
      rendered.should_not have_link("mxit_money")
    end

    it "wont have a mxit_money link not registered on mxit money" do
      @current_user.prize_points = 100
      @current_user.should_receive(:not_registered_on_mxit_money?).and_return(true)
      render
      rendered.should_not have_link("mxit_money")
    end

    it "wont have a mxit_money link if disabled in settings" do
      @current_user.prize_points = 100
      Settings.should_receive(:mxit_money_disabled_until).and_return(2.hours.from_now)
      render
      rendered.should_not have_link("mxit_money")
    end

  end

  context "vodago airtime" do

    it "must have R2 airtime and link" do
      @current_user.prize_points = 200
      render
      rendered.should have_content("R2 vodago airtime")
      rendered.should have_link("vodago_airtime",
                                href: new_redeem_winning_path(:prize_type => "vodago_airtime",
                                                              :prize_amount => 200))
    end

    it "must have R5 airtime and link" do
      @current_user.prize_points = 500
      render
      rendered.should have_content("R5 vodago airtime")
      rendered.should have_link("vodago_airtime",
                               href: new_redeem_winning_path(:prize_type => "vodago_airtime",
                                                             :prize_amount => 500))
    end

    it "must have R10 airtime and link" do
      @current_user.prize_points = 1000
      render
      rendered.should have_content("R10 vodago airtime")
      rendered.should have_link("vodago_airtime",
                               href: new_redeem_winning_path(:prize_type => "vodago_airtime",
                                                             :prize_amount => 1000))
    end

    it "must have a text if not enough prize points" do
      @current_user.prize_points = 199
      render
      rendered.should have_content("R2 vodago airtime")
    end

    it "wont have a link if not enough prize points" do
      @current_user.prize_points = 199
      render
      rendered.should_not have_link("vodago_airtime")
    end

  end

  context "mtn airtime" do

    it "must have R5 airtime and link" do
      @current_user.prize_points = 500
      render
      rendered.should have_content("R5 mtn airtime")
      rendered.should have_link("mtn_airtime",
                                href: new_redeem_winning_path(:prize_type => "mtn_airtime",
                                                              :prize_amount => 500))
    end

    it "must have R10 airtime and link" do
      @current_user.prize_points = 1000
      render
      rendered.should have_content("R10 mtn airtime")
      rendered.should have_link("mtn_airtime",
                                href: new_redeem_winning_path(:prize_type => "mtn_airtime",
                                                              :prize_amount => 1000))
    end

    it "must have R15 airtime and link" do
      @current_user.prize_points = 1500
      render
      rendered.should have_content("R15 mtn airtime")
      rendered.should have_link("mtn_airtime",
                                href: new_redeem_winning_path(:prize_type => "mtn_airtime",
                                                              :prize_amount => 1500))
    end

    it "must have a text if not enough prize points" do
      @current_user.prize_points = 499
      render
      rendered.should have_content("R5 mtn airtime")
    end

    it "wont have a link if not enough prize points" do
      @current_user.prize_points = 499
      render
      rendered.should_not have_link("mtn_airtime")
    end

  end

  context "cell_c airtime" do

    it "must have R5 airtime and link" do
      @current_user.prize_points = 500
      render
      rendered.should have_content("R5 cell c airtime")
      rendered.should have_link("cell_c_airtime",
                                href: new_redeem_winning_path(:prize_type => "cell_c_airtime",
                                                              :prize_amount => 500))
    end

    it "must have R10 airtime and link" do
      @current_user.prize_points = 1000
      render
      rendered.should have_content("R10 cell c airtime")
      rendered.should have_link("cell_c_airtime",
                                href: new_redeem_winning_path(:prize_type => "cell_c_airtime",
                                                              :prize_amount => 1000))
    end

    it "must have R25 airtime and link" do
      @current_user.prize_points = 2500
      render
      rendered.should have_content("R25 cell c airtime")
      rendered.should have_link("cell_c_airtime",
                                href: new_redeem_winning_path(:prize_type => "cell_c_airtime",
                                                              :prize_amount => 2500))
    end

    it "must have a text if not enough prize points" do
      @current_user.prize_points = 499
      render
      rendered.should have_content("R5 cell c airtime")
    end

    it "wont have a link if not enough prize points" do
      @current_user.prize_points = 499
      render
      rendered.should_not have_link("cell_c_airtime")
    end

  end

  context "virgin airtime" do

    it "must have R10 airtime and link" do
      @current_user.prize_points = 1000
      render
      rendered.should have_content("R10 virgin airtime")
      rendered.should have_link("virgin_airtime",
                                href: new_redeem_winning_path(:prize_type => "virgin_airtime",
                                                              :prize_amount => 1000))
    end

    it "must have R15 airtime and link" do
      @current_user.prize_points = 1500
      render
      rendered.should have_content("R15 virgin airtime")
      rendered.should have_link("virgin_airtime",
                                href: new_redeem_winning_path(:prize_type => "virgin_airtime",
                                                              :prize_amount => 1500))
    end

    it "must have R35 airtime and link" do
      @current_user.prize_points = 3500
      render
      rendered.should have_content("R35 virgin airtime")
      rendered.should have_link("virgin_airtime",
                                href: new_redeem_winning_path(:prize_type => "virgin_airtime",
                                                              :prize_amount => 3500))
    end

    it "must have a text if not enough prize points" do
      @current_user.prize_points = 999
      render
      rendered.should have_content("R10 virgin airtime")
    end

    it "wont have a link if not enough prize points" do
      @current_user.prize_points = 999
      render
      rendered.should_not have_link("virgin_airtime")
    end

  end

  context "heita airtime" do

    it "must have R5 airtime and link" do
      @current_user.prize_points = 500
      render
      rendered.should have_content("R5 heita airtime")
      rendered.should have_link("heita_airtime",
                                href: new_redeem_winning_path(:prize_type => "heita_airtime",
                                                              :prize_amount => 500))
    end

    it "must have R10 airtime and link" do
      @current_user.prize_points = 1000
      render
      rendered.should have_content("R10 heita airtime")
      rendered.should have_link("heita_airtime",
                                href: new_redeem_winning_path(:prize_type => "heita_airtime",
                                                              :prize_amount => 1000))
    end

    it "must have R20 airtime and link" do
      @current_user.prize_points = 2000
      render
      rendered.should have_content("R20 heita airtime")
      rendered.should have_link("heita_airtime",
                                href: new_redeem_winning_path(:prize_type => "heita_airtime",
                                                              :prize_amount => 2000))
    end

    it "must have a text if not enough prize points" do
      @current_user.prize_points = 499
      render
      rendered.should have_content("R5 heita airtime")
    end

    it "wont have a link if not enough prize points" do
      @current_user.prize_points = 499
      render
      rendered.should_not have_link("heita_airtime")
    end

  end

end
