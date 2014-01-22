# == Schema Information
#
# Table name: feedback
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  subject      :string(255)
#  message      :text
#  support_type :string(255)      default("suggestion")
#  created_at   :datetime
#  updated_at   :datetime
#

class Feedback < ActiveRecord::Base
  validates :message, presence: true

  belongs_to :user
  delegate :name, to: :user, prefix: true

  after_commit :send_to_uservoice, :on => :create

  def user_email
    user.account.email
  end

  def user_real_name
    user.account.real_name
  end

  def full_message=(v)
    self.message, self.subject = v.split(":",2).reverse
  end

  def full_message
    "#{subject}:#{message}"
  end

  protected

  def send_to_uservoice
    SendFeedbackToUservoice.perform_async(id)
  end

end

