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

  it "must have the correct fields" do
    puts @rendered
    within('form') do
      rendered.should have_css('#VendorId')
      rendered.should have_css('#TransactionReference')
      rendered.should have_css('#CallbackUrl')
      rendered.should have_css('#ProductId')
      rendered.should have_css('#ProductName')
      rendered.should have_css('#MoolaAmount')
      rendered.should have_css('#CurrencyAmount')
    end
  end

  it "renders a submit button" do
    within('form') do
      rendered.should have_button('submit')
    end
  end

  it "should have a home link" do
    rendered.should have_link("cancel", href: purchases_path)
  end

end
