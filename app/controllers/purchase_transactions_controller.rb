class PurchaseTransactionsController < ApplicationController
  before_filter :login_required, :except => ['simulate_purchase','index']
  load_and_authorize_resource :except => ['simulate_purchase']

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
        # if current_user.purchase_transactions.count >= 1 && current_user.badges(name: 'Mr. Loader', user_id:current_user.id).count == 0
        #   Badge.create(name: 'Mr. Loader', user_id:current_user.id)
        #   redirect_to({ action: 'index', mxit_transaction_res: params[:mxit_transaction_res]}, notice: "Purchase successful, Congratulations you received the #{view_context.link_to 'Mr. Loader', explain_path(action: 'mr_loader', id: 'mr_loader')} Badge".html_safe)
        # else
          redirect_to({ action: 'index', mxit_transaction_res: params[:mxit_transaction_res]}, notice: 'Purchase successful')
        # end
    else
      mxit_transaction_text = {1 => "Transaction rejected",
                               2 => "Authentication Failure",
                               3 => "Account is locked",
                               4 => "Insufficient funds",
                               5 => "Transaction timed out",
                               6 => "Logged out or Transaction rejected",
                               -2 => "transaction parameters are not valid",
                               -1 => "Technical system error occurred"}
      alert_text = mxit_transaction_text[params[:mxit_transaction_res].to_i]
      redirect_to({ action: 'index', mxit_transaction_res: params[:mxit_transaction_res]}, alert: alert_text)
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
