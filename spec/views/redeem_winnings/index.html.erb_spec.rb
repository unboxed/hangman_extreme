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

  it "should have a new_game link on menu" do
    view.should_receive(:menu_item).with(anything,new_game_path,id: 'new_game')
    render
  end

  it "should have a view rank link on menu" do
    view.should_receive(:menu_item).with(anything,user_path(50),id: 'view_rank')
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

  end

  ['vodago','cell_c','mtn'].each do |provider|

    context "#{provider} airtime" do

      it "must have R2 #{provider} airtime" do
        @current_user.prize_points = 500
        render
        rendered.should have_content("R5 #{provider.gsub("_"," ")} airtime")
      end

      it "must have a text if not enough prize points" do
        @current_user.prize_points = 499
        render
        rendered.should have_content("R5 #{provider.gsub("_"," ")} airtime")
      end

      it "must have a #{provider} airtime link" do
        @current_user.prize_points = 520
        render
        rendered.should have_link("#{provider}_airtime",
                                  href: new_redeem_winning_path(:prize_type => "#{provider}_airtime",
                                                                :prize_amount => 500))
      end

      it "wont have a #{provider} link if not enough prize points" do
        @current_user.prize_points = 499
        render
        rendered.should_not have_link("#{provider}_airtime")
      end

    end

  end

end
