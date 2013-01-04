class Settings

  def self.shinka_disabled_until
    return nil if APP_SETTINGS[:shinka_disabled_until].blank?
    Time.at(APP_SETTINGS[:shinka_disabled_until])
  end

  def self.shinka_disabled_until=(v)
    APP_SETTINGS[:shinka_disabled_until] = v && v.to_i
  end

  def self.ga_tracking_disabled_until
    return nil if APP_SETTINGS[:ga_tracking_disabled_until].blank?
    Time.at(APP_SETTINGS[:ga_tracking_disabled_until])
  end

  def self.ga_tracking_disabled_until=(v)
    APP_SETTINGS[:ga_tracking_disabled_until] = v && v.to_i
  end

  def self.cron_running!
    APP_SETTINGS[:cron_running] = Time.current.to_s
  end

end