require 'spec_helper'

describe AirtimeVouchersController do

  before :each do
    @current_user = create(:user)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can(:manage, :all)
    controller.should_receive(:current_ability).at_least(:once).and_return(@ability)
    controller.stub(:current_user).and_return(@current_user)
    controller.stub(:send_stats)
  end

  describe "GET index" do

    def do_get_index
      get :index
    end

    it "assigns all completed games as @games" do
      airtime_voucher = create(:airtime_voucher)
      do_get_index
      assigns(:airtime_vouchers).should eq([airtime_voucher])
    end

    it "renders the index" do
      do_get_index
      response.should render_template("airtime_vouchers/index")
    end

  end

end
