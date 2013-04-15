class UserSendMessage
  attr_accessor :msg, :users

  def initialize(msg,users)
    self.msg = msg
    self.users = users
  end

  def mxit_connection
    @mxit_connection ||= MxitApiWrapper.connect
  end

  def connected?
    !!mxit_connection
  end

  def send_all
    return false if users.empty?
    if connected?
      if users.kind_of?(ActiveRecord::Relation)
        users.mxit.find_in_batches(:batch_size => 100) do |user_batch|
          send_message_to_array(user_batch)
        end
      else
        users.uniq.in_groups_of(100,false).each do |user_batch|
          send_message_to_array(user_batch)
        end
      end
    else
      Airbrake.notify_or_ignore(
        Exception.new("Could not connect to mxit to send messages"),
        :parameters    => {:msg => msg, :users => users},
        :cgi_data      => ENV
      )
    end
  end

  private

  def send_message_to_array(batch)
    to = batch.delete_if{|u| u.provider != "mxit"}.collect(&:uid).join(",")
    mxit_connection.send_message(body: msg, to: to) unless to.blank?
  end

end