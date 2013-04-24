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

  def dialog_link_to(name,path,options = {})
    options.reverse_merge!('data-rel' => "dialog", 'data-transition' => "pop")
    smart_link_to(name,path,options)
  end

  def site_page_id(path = request.path)
    path == root_path ? "main_page" : "sub_page"
  end

end
