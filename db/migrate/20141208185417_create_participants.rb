class CreateParticipants < ActiveRecord::Migration
  def change
  	create_table :participants, force: true do |t|
    t.integer   :user_id,       null: false
    t.integer   :meetup_id,   null: false
    t.string   :participant_type,  null: false
    t.timestamps
  end
  end
end
