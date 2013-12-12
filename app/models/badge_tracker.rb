class BadgeTracker < ActiveRecord::Base
	belongs_to :user

	validates :user_id, presence: true

	validates_numericality_of :clues_revealed, only_integer: true, greater_than_or_equal_to: 0

end
