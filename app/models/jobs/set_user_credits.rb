class Jobs::SetUserCredits < Jobs::Base

  def run
    # perform work here
    User.where('credits < 12').update_all(credits: 12)
  end

end