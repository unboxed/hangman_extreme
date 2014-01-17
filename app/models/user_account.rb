# == Schema Information
#
# Table name: user_accounts
#
#  id            :integer          not null, primary key
#  uid           :string(255)      not null
#  provider      :string(255)      not null
#  real_name     :string(255)
#  mobile_number :string(255)
#  email         :string(255)
#  credits       :integer          default(24)
#  prize_points  :integer
#  lock_version  :integer          default(0), not null
#  created_at    :datetime
#  updated_at    :datetime
#

class UserAccount < ActiveRecord::Base
  validates :provider, :uid, presence: true
  validates_uniqueness_of :uid, :scope => :provider
end
