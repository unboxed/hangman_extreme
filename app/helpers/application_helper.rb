require 'open-uri'

module ApplicationHelper
  def smart_link_to(name,path,options = {})
    link_name, other = name.to_s.split(/\s/,2)
    link_to(link_name,path,options) + " #{other}"
  end

  def store_url
    "<a href=\"mxit://[mxit_recommend:Refresh]/Referral?from=#{ENV['MXIT_APP_NAME']}&to=#{ENV['STORE_MXIT_APP_NAME']}\" type=\"mxit/service-navigation\">Store</a><br/>"
  end
end
