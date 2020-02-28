class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes
  has_many :liked_posts, through: :likes, dependent: :destroy, source: :post
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user

  mount_uploader :picture, PictureUploader
  validate :picture_size
  def friend?(user)
    friendships.where(pending: false).find_by(friend_id: user.id) || inverse_friendships.where(pending: false).find_by(user_id: user.id)
  end

  def pending?(user)
    friend = friendships.find_by(friend_id: user.id)
    friend && friend.pending
  end

  def pending_request?
    pending_count = Friendship.where(pending: true).where(friend_id: id).length
    (pending_count > 0) ? pending_count : false
  end

  private
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "Should be less than 5MB")
      end
    end
end