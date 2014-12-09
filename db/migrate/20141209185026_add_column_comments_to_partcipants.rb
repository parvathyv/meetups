class AddColumnCommentsToPartcipants < ActiveRecord::Migration
  def change
  	 add_column :participants, :comment_title, :string
  	 add_column :participants, :comments, :text
  end
end
