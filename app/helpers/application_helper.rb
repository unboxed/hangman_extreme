module ApplicationHelper

  def shinka_ad
    begin
    ads = ActiveSupport::JSON.decode(open("http://ox-d.shinka.sh/ma/1.0/arj?auid=290386").read)
    ad = ads['ads']["ad"].sample
    ad["html"].html_safe
    rescue
       return ""
    end
  end

end
