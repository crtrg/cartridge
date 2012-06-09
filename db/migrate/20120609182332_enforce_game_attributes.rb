class EnforceGameAttributes < ActiveRecord::Migration
  def up
    change_column :games, :title,      :string,  :null => false
    change_column :games, :creator_id, :integer, :null => false
    change_column :games, :package,    :text,    :null => false
    add_foreign_key :games, :users, :column => 'creator_id'
  end

  def down
    change_column :games, :title,      :string
    change_column :games, :creator_id, :integer
    change_column :games, :package,    :binary
    remove_foreign_key :games, :users, :column => 'creator_id'
  end
end
