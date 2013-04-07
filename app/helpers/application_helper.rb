require 'open-uri'

module ApplicationHelper

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


  def smart_link_to(name,path,options = {})
    if mxit_request?
      link_name, other = name.to_s.split(/\s/,2)
      link_to(link_name,path,options) + " #{other}"
    else
      link_to(name,path,options)
    end
  end

  def dialog_link_to(name,path,options = {})
    options.reverse_merge!('data-rel' => "dialog", 'data-transition' => "pop")
    smart_link_to(name,path,options)
  end

  def inline_button(name,path,options)
    if mxit_request?
      link_name, other = name.split(/\s/,2)
      link_to(link_name,path,options) + " #{other} | "
    else
      link_to(name,path,options.reverse_merge('data-role' => "button", 'data-inline' => "true"))
    end
  end

  def site_page_id(path = request.path)
    "page#{path.gsub("/",'_')}_content"
  end

end
