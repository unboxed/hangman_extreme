# == Schema Information
#
# Table name: airtime_vouchers
#
#  id                  :integer          not null, primary key
#  redeem_winning_id   :integer
#  _deprecated_user_id :integer
#  freepaid_refno      :string(255)
#  network             :string(255)
#  pin                 :string(255)
#  sellvalue           :float
#  response            :text
#  created_at          :datetime
#  updated_at          :datetime
#  user_account_id     :integer
#

class AirtimeVoucher < ActiveRecord::Base
  belongs_to :redeem_winning
  belongs_to :user_account
  validates_presence_of :freepaid_refno, :network, :pin, :redeem_winning_id
  serialize :response
end
