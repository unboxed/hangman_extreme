class Jobs::SetUserCredits < Jobs::Base

  def run
    # perform work here
    User.where('credits < 20').update_all(credits: 20)
  end

end