def add_headers(headers)
  headers.each do |name, value|
    page.driver.browser.header(name, value)
  end
end

def visit_home
  visit '/' unless page.current_path == '/'
end

def setup_sessions(options = {})
  options.reverse_merge!(facebook: '1234567', mxit: 'm2604100')
  using_session(:mxit) do
    @mxit_user = User.find_mxit_user(options[:mxit]) || create(:user, uid: options[:mxit], provider: 'mxit')
    set_mxit_headers('m2604100') # set mxit user
  end
  Capybara.using_driver(:poltergeist) do
    using_session(:facebook) do
      @facebook_user = User.find_facebook_user(options[:facebook]) || create(:user, uid: options[:facebook], provider: 'facebook')
      using_facebook_omniauth{visit '/auth/facebook'}
    end
    using_session(:guest) do

    end
  end
end

def using_facebook_session
  Capybara.using_driver(:poltergeist) do
    using_session(:facebook) do
      yield
    end
  end
end

def using_mxit_session
  using_session(:mxit) do
    yield
  end
end

def using_guest_session
  Capybara.using_driver(:poltergeist) do
    using_session(:guest) do
      yield
    end
  end
end
