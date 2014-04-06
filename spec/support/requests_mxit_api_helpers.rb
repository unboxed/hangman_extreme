def set_mxit_headers(id = 'm2604100')
  add_headers('X_MXIT_USERID_R' => id,
              'X_MXIT_PROFILE' => 'en,ZA,1984-01-18,Male,2',
              'X_MXIT_LOCATION' => 'ZA,South Africa,11,Western Cape,23,Kraaifontein,88,13072382,8fbe253',
              'X_DEVICE_USER_AGENT' => 'iphone',
              'X_MXIT_LOGIN' => 'mxitlogin',
              'X_MXIT_NICK' => '#FF00FF_G_*r*/a$n$t/')
end

def stub_mxit_oauth(fields = {})
  # stub out mxit oauth
  body = Hash[fields.map {|k, v| [k.to_s.camelize, v] }].to_json
  stub_request(:get, /api\.mxit\.com\/user\/profile/).to_return(:status => 200, :body => body, :headers => {})
  token_body = '{ "scope":"contact/invite profile/public profile/private", "access_token":"c71219af53f5409e9d1db61db8a08248" }'
  stub_request(:post, /auth\.mxit\.com\/token/).to_return(:status => 200, :body => token_body, :headers => {})
  stub_request(:put, /api\.mxit\.com\/user\/socialgraph\/contact\/.*/).
    to_return(:status => 200, :body => '', :headers => {})
end

def stub_mxit_money(user_info = {:is_registered => false})
  stub_request(:get, 'https://:mxit_money_api@api.mxitmoney.co.za/paymentsplatform/rest/v3/push/').
    with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => {:balance => 123}.to_json, :headers => {})
  stub_request(:get, 'https://:mxit_money_api@api.mxitmoney.co.za/paymentsplatform/rest/v3/user/m2604100?idType=mxitId').
    with(:headers => {'Accept'=>'application/json', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => user_info.to_json, :headers => {})
end
