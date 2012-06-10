class AddCreatorFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :creator, :boolean
    User.all.each do |u|
      u.creator = true
      u.save
    end
    change_column :users, :creator, :boolean, :null => false
  end
end
