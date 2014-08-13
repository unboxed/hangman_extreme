def mxit_user(params_or_uid = 'm2604100')
  generate_user('mxit',params_or_uid)
end

def login_user(user)
  visit "/auth/callback?uid=#{user.uid}&provider=#{user.provider}"
end

def generate_user(provider,params_or_uid)
  if params_or_uid.kind_of?(String)
    User.find_by_provider_and_uid(provider,params_or_uid) || create(:user, uid: params_or_uid, provider: provider)
  else
    params = HashWithIndifferentAccess.new(params_or_uid).reverse_merge(uid: '1234567').merge(provider: provider)
    user = User.find_by_provider_and_uid(provider,params[:uid])
    if user
      user.update_attributes(params)
      user
    else
      create(:user, params)
    end
  end
end
