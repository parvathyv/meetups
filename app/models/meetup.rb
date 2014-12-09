class Meetup < ActiveRecord::Base
	validates :name, presence: true
	has_many :partcipants
	has_many :users, through: :participants
end

