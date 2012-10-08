class GoogleTracking < Ohm::Model
  include Ohm::Expire
  TTL = 1.day.to_i

  attribute :user_id
  index :user_id
  unique :user_id
  attribute :initial_visit
  attribute :previous_session
  attribute :current_session

  def initialize(values = {})
    now = Time.now.to_i
    values.reverse_merge!(current_session: now,
                          previous_session: now,
                          initial_visit: now)
    super(values)
  end

  def update_tracking
    self.previous_session = self.current_session
    self.current_session = Time.now.to_i
    update_ttl if save
  end

  def self.find_or_create_by_user_id(user_id)
    find(user_id: user_id).first(by: 'user_id') || create(user_id: user_id)
  end

end