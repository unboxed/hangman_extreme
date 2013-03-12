class AirtimeVoucher < ActiveRecord::Base
  belongs_to :redeem_winning
  belongs_to :user
  attr_accessible :freepaid_refno, :network, :response, :sellvalue, :pin, :redeem_winning, :user
  validates_presence_of :freepaid_refno, :network, :pin, :redeem_winning_id
  serialize :response
end
