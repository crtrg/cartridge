class AddPushTokenToGames < ActiveRecord::Migration
  def change
    add_column :games, :push_token, :string, :length => 24
    Game.all.each do |g|
      g.generate_push_token
      g.save
    end
    change_column :games, :push_token, :string, :null => false, :length => 24
  end
end
