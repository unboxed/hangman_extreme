require 'ohm/contrib'
require 'securerandom'

class GoogleTracking < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  include ActiveModel::Validations
  include ActiveModel::Dirty
  define_attribute_methods [:user_id, :uuid, :last_visit]

  attribute :user_id
  index :user_id
  unique :user_id
  attribute :uuid
  attribute :last_visit, Type::Time

  validates_presence_of :user_id

  def save
    (new? || changed?) && super
  end

  def self.time_now
    Time.at((Time.current.to_i / 60) * 60)
  end

  def update_tracking
    now = GoogleTracking.time_now
    if last_visit.nil? || (now > last_visit + 1.hour)
      self.uuid = SecureRandom.uuid
    end
    self.last_visit = now
    save
  end

  def tracking_uuid(update_tracking = false)
    self.update_tracking if update_tracking
    uuid
  end

  def self.tracking_uuid(user_id)
    t = find(user_id: user_id.to_s).first ||
    create(user_id: user_id.to_s,
           uuid: SecureRandom.uuid,
           last_visit: GoogleTracking.time_now)
    t.tracking_uuid
  end
end
