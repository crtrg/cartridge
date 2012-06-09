class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :title
      t.integer :creator_id
      t.binary :package

      t.timestamps
    end
  end
end
