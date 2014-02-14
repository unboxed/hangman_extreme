# == Schema Information
#
# Table name: redeem_winnings
#
#  id                   :integer          not null, primary key
#  _deprecated_user_id  :integer
#  prize_amount         :integer
#  prize_type           :string(255)
#  state                :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  mxit_money_reference :text
#  user_account_id      :integer
#

class Deprecated::RedeemWinning < ActiveRecord::Base
  self.table_name = 'redeem_winnings'
end
