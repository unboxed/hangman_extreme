class AirtimeVoucher < ActiveRecord::Base
  belongs_to :redeem_winning
  belongs_to :user
  validates_presence_of :freepaid_refno, :network, :pin, :redeem_winning_id
  serialize :response
end
