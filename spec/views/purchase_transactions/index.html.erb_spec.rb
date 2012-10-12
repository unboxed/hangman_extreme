require 'spec_helper'

describe "purchase_transactions/index.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @users =
      assign(:users, [
        stub_model(User, id: 100, name: "hello", daily_rating: "123"),
        stub_model(User, id: 101, name: "goodbye", daily_rating: "345")
      ])
    view.stub!(:current_user).and_return(stub_model(User, id: 50))
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

  it "should have a home page link" do
    render
    rendered.should have_link("root_page", href: '/')
  end

end
