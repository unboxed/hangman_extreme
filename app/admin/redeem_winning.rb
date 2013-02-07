ActiveAdmin.register RedeemWinning do

  index do
    column :id
    column :state
    column :prize_type
    column :user_uid
    column :user_login
    column :user_mobile_number
    column :prize_amount
    default_actions
  end

  member_action :paid, :method => :put do
    RedeemWinning.paid!(params[:id])
    redirect_to({:action => :index}, :notice => "Paid!")
  end

end                                   
