require 'open-uri'

module AdHelper

  def shinka_ad
    if shinka_ads_enabled?
      "<mxit:advert auid=\"#{shinka_auid}\"/>".html_safe
    else
      ''
    end
  end

  def smaato_ads_enabled?
    smaato_pub.present? && smaato_adspace.present? && !Rails.env.test?
  end

  def shinka_ads_enabled?
    shinka_auid.present?
  end

  def shinka_auid
    ENV['SHINKA_AUID']
  end

  def smaato_adspace
    ENV['SOMA_ADSPACE']
  end

  def smaato_pub
    ENV['SOMA_PUB']
  end

  def env
    request.env
  end

  def request_ip_address
    env['HTTP_X_FORWARDED_FOR'] || env['HTTP_X_CLIENT'] || env['REMOTE_ADDR']
  end

end
