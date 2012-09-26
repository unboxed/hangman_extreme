module ApplicationHelper

  def shinka_ad
    result = ""
    begin
    ads = ActiveSupport::JSON.decode(open("http://ox-d.shinka.sh/ma/1.0/arj?auid=290386c.age=#{@mxit_profile.age}&c.gender=#{@mxit_profile.gender}&c.country=#{@mxit_profile.country}").read)
    ad = ads['ads']["ad"].sample
    result = ad["html"].html_safe
    impression = ad["creative"].first["tracking"]["impression"]
    alt = ad["creative"].first["alt"]
    click = ad["creative"].first["tracking"]["click"]
    if alt.include?("http:")
      result
    else
      "<img href=#{impression} /><a href=#{click} onclick='window.open(this.href); return false;' >#{alt}</a>".html_safe
    end
    rescue Exception => e
      Rails.logger.error e.message
       return result
    end
  end

end
