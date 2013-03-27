class Settings
  include Dynamoid::Document

  validates_presence_of :name

  field :name
  index :name
  field :value


  def self.shinka_disabled_until_setting
    where(name: 'shinka_disabled_until').try(:first) || new(name: 'shinka_disabled_until', value: 0)
  end

  def self.shinka_disabled_until
    Time.at(shinka_disabled_until_setting.value.to_i)
  end

  def self.shinka_disabled_until=(v)
    shinka_disabled_until_setting.update_attribute(:value,v.to_i)
  end

  def self.ga_tracking_disabled_untill_setting
    where(name: 'ga_tracking_disabled_until').try(:first) || new(name: 'ga_tracking_disabled_until', value: 0)
  end

  def self.ga_tracking_disabled_until
    Time.at(ga_tracking_disabled_untill_setting.value.to_i)
  end

  def self.ga_tracking_disabled_until=(v)
    ga_tracking_disabled_untill_setting.update_attribute(:value,v.to_i)
  end

end