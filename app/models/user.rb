class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me

  # attr_accessible :title, :body

  has_many :games, :as => :creator

  validates_presence_of :username
  validates_exclusion_of :username, :in => %w( admin superuser system ), :message => "Sorry, that name is reserved :("
  profanity_filter :username
  before_create :set_creator

  private
  def set_creator
    self.creator = Time.now < Time.parse("June 11, 2012")
  end
end
