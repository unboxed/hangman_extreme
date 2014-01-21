require 'view_spec_helper'

describe "purchase_transactions/index.html.erb" do

  before(:each) do
    @current_user_account = stub_model(UserAccount, id: 50)
    view.stub(:current_user_account).and_return(@current_user_account)
    view.stub(:menu_item)
    view.stub(:mxit_request?).and_return(true)
    view.stub(:guest?)
    PurchaseTransaction.stub(:purchases_enabled?).and_return(true)
  end


  it "must list all the products that can be purchased" do
    render
    PurchaseTransaction.products.each do |product_id,hash|
      within("#product_#{product_id}") do
        rendered.should have_content(hash[:product_name])
        rendered.should have_link("buy_#{product_id}", href: new_purchase_path(product_id: product_id))
      end
    end
  end

  it "wont list all the products that can be purchased if not mxit request" do
    view.stub(:mxit_request?).and_return(false)
    render
    PurchaseTransaction.products.each do |product_id,hash|
      rendered.should_not have_link("buy_#{product_id}", href: new_purchase_path(product_id: product_id))
    end
  end

  it "should have a profile link on menu unless guest" do
    view.stub(:guest?).and_return(false)
    view.should_receive(:menu_item).with(anything,user_accounts_path,id: 'profile')
    render
  end

  it "wont have a profile link on menu if guest" do
    view.stub(:guest?).and_return(true)
    view.should_not_receive(:menu_item).with(anything,user_accounts_path,id: 'profile')
    render
  end

end
