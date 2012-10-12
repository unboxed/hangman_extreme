require 'spec_helper'

describe "purchase_transactions/new.html.erb" do
  include ViewCapybaraRendered

  before(:each) do
    @purchase_transaction = assign(:purchase_transaction,
                                   stub_model(PurchaseTransaction,
                                              product_name: '10 points',
                                              moola_amount: 10))
    render
  end

  it "renders product details" do
    rendered.should have_content('10 points')
    rendered.should have_content('10 moola')
  end

  it "renders a submit button" do
    within('form') do
      rendered.should have_button('submit')
    end
  end

  it "should have a home link" do
    rendered.should have_link("cancel", href: root_path)
  end

end
