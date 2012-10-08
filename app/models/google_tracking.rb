class GoogleTracking < Ohm::Model
  attribute :user_id
  index :user_id
  unique :user_id
  attribute :initial_visit
  attribute :previous_session
  attribute :current_session

  def update_tracking
    self.previous_session = self.current_session
    self.current_session = Time.now.to_i
    save
  end

  def self.find_or_create_by_user_id(user_id)
    now = Time.now.to_i
    find(user_id: user_id.to_s).first ||
    create(user_id: user_id.to_s,
           current_session: now,
           previous_session: now,
           initial_visit: now)
  end

end