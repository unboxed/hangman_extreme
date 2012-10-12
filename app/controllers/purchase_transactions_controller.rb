class PurchaseTransactionsController < ApplicationController
  before_filter :login_required, :except => :simulate_purchase
  load_and_authorize_resource :except => [:simulate_purchase]

  def index
    @purchase_transactions = @purchase_transactions.page(params[:page])
  end

  def new
    @purchase_transaction.product_id = params[:product_id]
    @ref = @purchase_transaction.generate_ref
    redirect_to({action: 'index'}, alert: 'Invalid product code') if @purchase_transaction.product_name.blank?
  end

  def create
    if params[:mxit_transaction_res].to_i == 0
      @purchase_transaction.user = current_user
      @purchase_transaction.product_id = params[:product_id]
      @purchase_transaction.ref = params[:ref]
      @purchase_transaction.save!
      redirect_to({ action: 'index'}, notice: 'Purchase successful')
    else
      alert_text =
      case params[:mxit_transaction_res].to_i
        when 1
          "Transaction rejected"
        when 2
          "Authentication Failure"
        when 3
          "Account is locked"
        when 4
          "Insufficient funds"
        when 5
          "Transaction timed out"
        when 6
          "Logged out or Transaction rejected"
        when -2
          "transaction parameters are not valid"
        when -1
          "Technical system error occurred"
      end
      redirect_to({ action: 'index'}, alert: alert_text)
    end
  end

  def simulate_purchase
    raise if Rails.env.production?
    redirect_to action: 'create',
                product_id: params['ProductId'],
                ref: params['TransactionReference'],
                mxit_transaction_res: 0
  end

end
