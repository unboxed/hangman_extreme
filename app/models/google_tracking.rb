class GoogleTracking
  include Dynamoid::Document

  validates_presence_of :user_id

  field :user_id
  index :user_id
  # unique :user_id
  field :initial_visit
  field :previous_session
  field :current_session
  field :last_visit

  def update_tracking
    now = Time.now.to_i
    if (Time.now.to_i - last_visit.to_i > 1.hour.to_i)
      self.previous_session = self.current_session
      self.current_session = now
    end
    self.last_visit = now
    save
  end

  def self.find_or_create_by_user_id(user_id)
    now = Time.now.to_i
    where(user_id: user_id.to_s).first ||
    create(user_id: user_id.to_s,
           current_session: now,
           previous_session: now,
           initial_visit: now,
           last_visit: now)
  end

end