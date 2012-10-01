class UserRequestInfo

  attr_accessor :user_agent, :language, :gender, :age, :country, :area

  def initialize(values = {})
    values.each do |key,value|
      self.send("#{key}=".to_sym,value.to_s)
    end
  end

  def mxit_profile=(mxit_profile)
    self.age = mxit_profile.age
    self.country = mxit_profile.country
    self.gender = mxit_profile.gender
    self.language = mxit_profile.language
  end

  def mxit_location=(mxit_location)
    self.country = mxit_location.country_name
    self.area = mxit_location.principal_subdivision_name
  end

end