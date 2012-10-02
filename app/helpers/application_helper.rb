module ApplicationHelper

  def shinka_ad
    result = Settings.last_shinka_ad.try(:html_safe) || ""
    return result unless shinka_ads_enabled?
    begin
      Timeout::timeout(15) do
        ads = ActiveSupport::JSON.decode(open("http://ox-d.shinka.sh/ma/1.0/arj?auid=#{shinka_auid}&c.age=#{current_user_request_info.age}&c.gender=#{current_user_request_info.gender}&c.country=#{current_user_request_info.country}").read)
        ad = ads['ads']["ad"].sample
        result = ad["html"].html_safe
        creative = ad["creative"].first
        tracking = creative["tracking"]
        alt = creative["alt"]
        if alt.blank? || alt.include?("http")
          link = creative["media"]
          return "" if link.blank? || !link.include?("href=")
          link.gsub!("href=","onclick='window.open(this.href); return false;' href=")
          Settings.last_shinka_ad = "<img href=#{tracking['impression']} alt=\"\" height=\"1\" width=\"1\"/>#{link}".html_safe
        else
          Settings.last_shinka_ad = "<img href=#{tracking['impression']} alt=\"\" height=\"1\" width=\"1\"/><a href=#{tracking['click']} onclick='window.open(this.href); return false;' >#{alt}</a>".html_safe
        end
      end
    rescue Exception => e
      ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
      Settings.shinka_disabled_until = 10.minutes.from_now # disable for a hour
      Rails.logger.error e.message
      return result
    end
  end

  def shinka_ads_enabled?
    (Settings.shinka_disabled_until.blank? || Time.current > Settings.shinka_disabled_until) &&
      shinka_auid.present?
  end

  def shinka_auid
    ENV['SHINKA_AUID']
  end

end
