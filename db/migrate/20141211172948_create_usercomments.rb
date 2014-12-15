class CreateUsercomments < ActiveRecord::Migration
  def change
  	create_table :usercomments, force: true do |t|
    t.integer   :participant_id,       null: false
    t.string   :comment_title   
    t.text   :comments  
    t.timestamps
  end
  remove_column :participants, :comment_title, :string
  remove_column :participants, :comments, :text
 end 
end
