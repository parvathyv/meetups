class Participant <  ActiveRecord::Base
	belongs_to :user
	belongs_to :meetup
	has_many :usercomments
	validates :participant_type, presence: true
	
end