require 'spec_helper'

describe "purchase_transactions/index.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @current_user = stub_model(User, id: 50)
    @users =
      assign(:users, [
        stub_model(User, id: 100, name: "hello", daily_rating: "123"),
        stub_model(User, id: 101, name: "goodbye", daily_rating: "345")
      ])
    view.stub!(:current_user).and_return(@current_user)
    view.stub!(:menu_item)
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

  it "should have a home link on menu" do
    view.should_receive(:menu_item).with(anything,'/',id: 'root_page')
    render
  end

  it "should have a profile link on menu" do
    view.should_receive(:menu_item).with(anything,profile_users_path,id: 'profile')
    render
  end

  it "should have a continue link on menu if there is a game to continue" do
    @current_user.stub!(:current_game).and_return(stub_model(Game, id: 10))
    view.should_receive(:menu_item).with(anything,game_path(10),id: 'continue')
    render
  end

end
