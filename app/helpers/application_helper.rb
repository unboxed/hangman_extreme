module ApplicationHelper

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
    Rails.env.test? ? (env["HTTP_X_FORWARDED_FOR"] || request.env['REMOTE_ADDR']) : env["HTTP_X_FORWARDED_FOR"]
  end

  def mxit_authorise_link(name,url_options,options = {})
    link_to(name,mxit_auth_url(url_options),options)
  end

  def mxit_auth_url(url_options)
    mxit_authorise_url(url_options.reverse_merge(response_type: 'code',
                               host: Rails.env.test? ? request.host : "auth.mxit.com",
                               protocol: Rails.env.test? ? 'http' : 'https',
                               client_id: ENV['MXIT_CLIENT_ID'],
                               redirect_uri: mxit_oauth_users_url(host: request.host),
                               scope: "profile/public profile/private"))
  end

  def smart_link_to(name,*args)
    link_text, left_text = name.split(/\s/,2)
    link_to(link_text,*args) + " #{left_text.to_s}"
  end


  def smart_link_to(name,path,options)
    if mxit_request?
      link_name, other = name.split(/\s/,2)
      link_to(link_name,path,options) + " #{other}"
    else
      link_to(name,path,options)
    end
  end

  def site_page_id(path = request.path)
    "page#{path.gsub("/",'_')}_content"
  end

end
