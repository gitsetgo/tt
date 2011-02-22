class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable, :confirmable and :activatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation

  # :dependent => :destroy ensures that all a user's videos are destroyed when
  # the user is destroyed.
  has_many :videos, :dependent => :destroy

  def video_feed
    Video.where("user_id = ?", id)
  end

end
