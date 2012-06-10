class AddRemixableToGames < ActiveRecord::Migration
  def change
    add_column :games, :remixable, :boolean
    add_column :games, :is_a_remix, :boolean
    add_column :games, :original_id, :integer
  end
end
