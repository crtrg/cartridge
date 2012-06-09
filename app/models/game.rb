class Game < ActiveRecord::Base
  attr_accessible :package, :title
  profanity_filter :title

  belongs_to :creator, class_name: 'User'
end
