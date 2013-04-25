require 'open-uri'

module ApplicationHelper

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

end
