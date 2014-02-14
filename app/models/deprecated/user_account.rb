# == Schema Information
#
# Table name: user_accounts
#
#  id            :integer          not null, primary key
#  uid           :string(255)      not null
#  provider      :string(255)      not null
#  mxit_login    :string(255)
#  real_name     :string(255)
#  mobile_number :string(255)
#  email         :string(255)
#  credits       :integer          default(24)
#  prize_points  :integer          default(0)
#  lock_version  :integer          default(0), not null
#  created_at    :datetime
#  updated_at    :datetime
#

class Deprecated::UserAccount < ActiveRecord::Base
  self.table_name = 'user_accounts'
end
