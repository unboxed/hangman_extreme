class Badge < ActiveRecord::Base
  belongs_to :user
  validates :name, :user_id,  presence: true
  
  VALID_NAME = ["Mr. Loader", "Bookworm", "Clueless"]
  validates_inclusion_of :name, :in => VALID_NAME

  validates_uniqueness_of :name, :scope => :user_id

end
