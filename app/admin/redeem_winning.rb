ActiveAdmin.register RedeemWinning do

  index do
    column :id
    column :state
    column :prize_type
    column :user_uid
    column :user_login
    column :user_mobile_number
    column :prize_amount
    column :created_at
    column "" do |resource|
      link_to('Paid', paid_admin_redeem_winning_path(resource), :method => :put) unless resource.paid?
    end
  end

  member_action :paid, :method => :put do
    RedeemWinning.paid!(params[:id])
    redirect_to({:action => :index}, :notice => "Paid!")
  end

end                                   
