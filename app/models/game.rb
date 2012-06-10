class Game < ActiveRecord::Base
  attr_accessible :package, :title, :remixable

  profanity_filter :title

  belongs_to :creator, class_name: 'User'
  before_create :generate_push_token

  belongs_to :original, class_name: Game
  has_many :remixes, class_name: Game, foreign_key: :original_id

  def generate_push_token
    self.push_token = SecureRandom.hex(24)
  end
end
