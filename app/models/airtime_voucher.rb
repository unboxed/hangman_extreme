# == Schema Information
#
# Table name: airtime_vouchers
#
#  id                :integer          not null, primary key
#  redeem_winning_id :integer
#  user_id           :integer
#  freepaid_refno    :string(255)
#  network           :string(255)
#  pin               :string(255)
#  sellvalue         :float
#  response          :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class AirtimeVoucher < ActiveRecord::Base
  belongs_to :redeem_winning
  belongs_to :user
  validates_presence_of :freepaid_refno, :network, :pin, :redeem_winning_id
  serialize :response
end
