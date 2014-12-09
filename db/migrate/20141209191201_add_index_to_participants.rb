class AddIndexToParticipants < ActiveRecord::Migration
  def change
  	add_index :participants, [:user_id, :meetup_id], :unique => true
  end
end
