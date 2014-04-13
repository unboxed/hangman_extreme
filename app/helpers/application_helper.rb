require 'open-uri'

module ApplicationHelper
  def smart_link_to(name,path,options = {})
    if mxit_request?
      link_name, other = name.to_s.split(/\s/,2)
      link_to(link_name,path,options) + " #{other}"
    else
      link_to(name,path,options.merge(:data => {:push => true}))
    end
  end

  def store_url
    if mxit_request?
      "<a href=\"mxit://[mxit_recommend:Refresh]/Referral?from=#{ENV['MXIT_APP_NAME']}&to=#{ENV['STORE_MXIT_APP_NAME']}\" type=\"mxit/service-navigation\">Store</a><br/>"
    else
      link_to 'store', ENV['STORE_URL']
    end
  end
end
