module MxitHelper

  def mxit_authorise_link(name,url_options,options = {})
    link_to(name,mxit_auth_url(url_options),options)
  end

  def mxit_auth_url(url_options)
    mxit_authorise_url(url_options.reverse_merge(response_type: 'code',
                                                 host: Rails.env.test? ? request.host : "auth.mxit.com",
                                                 protocol: Rails.env.test? ? 'http' : 'https',
                                                 client_id: ENV['MXIT_CLIENT_ID'],
                                                 redirect_uri: mxit_oauth_users_url(host: request.host),
                                                 scope: "profile/public profile/private")).html_safe
  end


  def mxit_dash
    mxit_only('-')
  end

  def mxit_only(text)
    mxit_request? ? text : ""
  end

end
