require 'spec_helper'

describe PurchaseTransactionsController do

  before :each do
    @current_user = create(:user)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @ability.can(:manage, :all)
    controller.stub(:current_ability).and_return(@ability)
    controller.stub(:current_user).and_return(@current_user)
  end

  describe "GET index" do

    def do_get_index
      get :index
    end

    it "assigns all purchase transactions as @purchase_transactions" do
      trans = create(:purchase_transaction, user: @current_user)
      do_get_index
      assigns(:purchase_transactions).should eq([trans])
    end

    it "renders the application layout" do
      do_get_index
      response.should render_template("layouts/application")
    end

  end

  describe "GET new" do

    def do_get_new
      get :new, product_id: PurchaseTransaction.products.keys.first
    end

    it "assigns a new purchase_transaction as @purchase_transaction" do
      do_get_new
      assigns(:purchase_transaction).should be_a_new(PurchaseTransaction)
    end

    it "redirects to index if no product_id set" do
      get :new
      response.should redirect_to(action: 'index')
    end

  end

  describe "GET create" do

    def do_get_create(response = 0)
      @gabba = mock('connection',:transaction => '')
      Gabba::Gabba.stub(:new).and_return(@gabba)
      get :create, product_id: PurchaseTransaction.products.keys.first, ref: 'a123', mxit_transaction_res: response
    end

    it "assigns a newly created purchase_transaction as @purchase_transaction" do
      do_get_create
      assigns(:purchase_transaction).should be_kind_of(PurchaseTransaction)
      assigns(:purchase_transaction).should be_persisted
      assigns(:purchase_transaction).user.should == @current_user
      assigns(:purchase_transaction).ref.should == 'a123'
    end

    it "redirects to index" do
      do_get_create
      response.should redirect_to(action: 'index')
    end

    context "faild" do

      it "wont create if response != 0" do
        do_get_create(1)
        assigns(:purchase_transaction).should be_kind_of(PurchaseTransaction)
        assigns(:purchase_transaction).should_not be_persisted
        flash[:alert].should_not be_blank
      end

      it "wont notify google" do
        do_get_create(1)
        Gabba::Gabba.should_not_receive(:new)
      end

    end

  end

end
