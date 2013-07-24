require 'open-uri'

module AdHelper

  def shinka_ad
    if shinka_ads_enabled?
      "<mxit:advert auid=\"#{shinka_auid}\"/>"
    else
      ""
    end
  end

  def smaato_ad(extra = "")
    begin
      Timeout::timeout(5) do
        headers = {"User-Agent" => env['HTTP_USER_AGENT'] || "Ruby",
                   "X-FORWARDED-FOR" => request_ip_address}
        open("http://soma.smaato.net/oapi/reqAd.jsp?apiver=413&response=HTML&adspace=#{ENV['SOMA_ADSPACE']}&pub=#{ENV['SOMA_PUB']}#{extra.to_s}",headers).read.html_safe
      end
    rescue Errno::ECONNREFUSED => refuse_error
      Rails.logger.error(refuse_error.message)
      return ""
    rescue Exception => e
      ENV['AIRBRAKE_API_KEY'].present? ? notify_airbrake(e) : Rails.logger.error(e.message)
      raise unless Rails.env.production?
      return ""
    end
  end

  def shinka_ads_enabled?
    shinka_auid.present?
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