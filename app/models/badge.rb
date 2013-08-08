class Badge < ActiveRecord::Base
 
  belongs_to :user
  attr_accessible :name, :user_id
  validates :name, :user_id,  presence: true 
  
  VALID_NAME = ["Mr. Loader"]
  validates_inclusion_of :name, :in => VALID_NAME

  validates_uniqueness_of :name, :scope => :user_id

end
