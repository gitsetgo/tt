class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable,
  # :confirmable and :activatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation,
                  :name, :username, :avatar

  # :dependent => :destroy ensures that all a user's videos are destroyed when
  # the user is destroyed.
  has_many :videos, :dependent => :destroy

  # get profile pic using paperclip
  # store two versions: thumbnail (32x32) and medium (300x300)
  has_attached_file :avatar,
                    :default_url => "default_avatar.jpg",
                    :styles => {
                      :thumb => "32x32#",
                      :medium => "300x300>"
                    },
                    :dependent => :destroy
  # validates_attachment_presence :avatar
  validates_attachment_size :avatar, :less_than => 5.megabytes
  validates_attachment_content_type :avatar,
                                    :content_type => ['image/jpeg', 'image/png',
                                                      'image/gif']
  # paperclip extended validations
  validates_attachment_extension :avatar,
                                 :extensions => %w[jpg jpeg gif png]

  def video_feed
    Video.where("user_id = ?", id)
  end

end
