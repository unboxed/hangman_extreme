require "spec_helper"

describe PurchaseTransactionsController do
  describe "routing" do

    it "routes to #simulate_purchase" do
      get("/Transaction/PaymentRequest").should route_to("purchase_transactions#simulate_purchase")
    end

    it "routes to #index" do
      get("/purchase_transactions").should route_to("purchase_transactions#index")
    end

    it "routes to #new" do
      get("/purchase_transactions/new").should route_to("purchase_transactions#new")
    end

    it "routes to #create" do
      get("/purchase_transactions/create").should route_to("purchase_transactions#create")
    end

  end
end
