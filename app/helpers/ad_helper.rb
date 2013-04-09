require 'open-uri'

module AdHelper

  def shinka_ad
    return "" unless shinka_ads_enabled?
    ad = get_shinka_ad
    return "" if ad.empty?
    result = ad["html"].gsub("href=","onclick='window.open(this.href); return false;' href=").html_safe
    creative = ad["creative"].first
    tracking = creative["tracking"]
    alt = creative["alt"]
    beacon = "<div class='beacon' style='position: absolute; left: 0px; top: 0px; visibility: hidden;'>"
    beacon << "<img src='#{tracking['impression']}' alt=\"\" height=\"1\" width=\"1\"/>"
    beacon << "</div>"
    if alt.blank? || alt.include?("http")
      link = creative["media"]
      return result if link.blank? || !link.include?("href=")
      link.gsub!("href=","onclick='window.open(this.href); return false;' href=")
      "#{beacon}#{link}".html_safe
    else
      "#{beacon}<a href=#{tracking['click']} onclick='window.open(this.href); return false;' >#{alt}</a>".html_safe
    end
  end

  def shinka_img_ad
    return "" unless shinka_ads_enabled?
    ad = get_shinka_ad
    return "" if ad.empty?
    ad["html"].gsub("href=","onclick='window.open(this.href); return false;' href=").html_safe
  end

  def smaato_ad
    headers = {"User-Agent" => env['HTTP_USER_AGENT'] || "Ruby",
               "X-FORWARDED-FOR" => request_ip_address}
    open("http://soma.smaato.net/oapi/reqAd.jsp?apiver=413&response=HTML&adspace=#{ENV['SOMA_ADSPACE']}&pub=#{ENV['SOMA_PUB']}",headers).read.html_safe
  end

  def get_shinka_ad
    begin
      Rails.logger.info "Get Shinka Ad"
      Timeout::timeout(5) do
        headers = {"User-Agent" => "Mozilla Compatible/5.0 #{env['HTTP_USER_AGENT']}",
                   "X-FORWARDED-FOR" => request_ip_address}
        ads = ActiveSupport::JSON.decode(open("http://ox-d.shinka.sh/ma/1.0/arj?auid=#{shinka_auid}&c.age=#{current_user_request_info.age}&c.gender=#{current_user_request_info.gender}",headers).read)
        return {} if ads['ads']['count'].to_i == 0
        ads['ads']["ad"].sample
      end
    rescue Timeout::Error => time_error
      Rails.logger.error(time_error.message)
      Settings.shinka_disabled_until = 1.minute.from_now # disable for 1 minute
      return {}
    rescue Exception => e
      ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
      Settings.shinka_disabled_until = 10.minutes.from_now # disable for a hour
      raise unless Rails.env.production?
      return {}
    end
  end


  def shinka_ads_enabled?
    shinka_auid.present? &&
      (Settings.shinka_disabled_until.blank? || Time.current > Settings.shinka_disabled_until)
  end

  def shinka_auid
    ENV['SHINKA_AUID']
  end

  def env
    request.env
  end

  def request_ip_address
    env["HTTP_X_FORWARDED_FOR"] || env['HTTP_X_CLIENT'] || env['REMOTE_ADDR']
  end

end