class Settings < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes

  attribute :name
  index :name
  unique :name
  attribute :value

  def validate
    assert_present :name
  end

  def self.shinka_disabled_until_setting
    find(name: 'shinka_disabled_until').first || create(name: 'shinka_disabled_until', value: 0)
  end

  def self.shinka_disabled_until
    Time.at(shinka_disabled_until_setting.value.to_i)
  end

  def self.shinka_disabled_until=(v)
    shinka_disabled_until_setting.update(:value => v.to_i)
  end

  def self.ga_tracking_disabled_untill_setting
    find(name: 'ga_tracking_disabled_until').first || create(name: 'ga_tracking_disabled_until', value: 0)
  end

  def self.ga_tracking_disabled_until
    Time.at(ga_tracking_disabled_untill_setting.value.to_i)
  end

  def self.ga_tracking_disabled_until=(v)
    ga_tracking_disabled_untill_setting.update(:value => v.to_i)
  end

end