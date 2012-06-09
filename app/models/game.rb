class Game < ActiveRecord::Base
  attr_accessible :package, :title

  belongs_to :creator, class_name: 'User'
end
