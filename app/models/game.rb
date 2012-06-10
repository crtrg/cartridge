class Game < ActiveRecord::Base
  attr_accessible :package, :title
  profanity_filter :title

  belongs_to :creator, class_name: 'User'
  before_create :generate_push_token

  def generate_push_token
    self.push_token = SecureRandom.hex(24)
  end
end
