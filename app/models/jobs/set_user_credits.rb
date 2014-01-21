class Jobs::SetUserCredits < Jobs::Base

  def run
    # perform work here
    UserAccount.where('credits < 18').update_all(credits: 18)
  end

end
