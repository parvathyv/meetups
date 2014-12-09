class Participant <  ActiveRecord::Base
	belongs_to :user
	belongs_to :meetup
	validates :participant_type, presence: true
	
end