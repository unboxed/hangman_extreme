def add_headers(headers)
  headers.each do |name, value|
    page.driver.browser.header(name, value)
  end
end

def visit_home
  visit '/' unless page.current_path == '/'
end
