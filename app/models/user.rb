class User < ActiveRecord::Base
  attr_accessor :remember_token

  has_many :lessons, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                  foreign_key: "followed_id",
                                  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_secure_password

  validates :name, presence: true, length: {maximum: Settings.length.short_maximum}
  validates :email, presence: true, length: {maximum: Settings.length.long_maximum},
                    format: {with: Settings.VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false},
                    if: "new_record?"
  validates :password, length: {minimum: Settings.length.minimum}, if: "password_set?"

  has_secure_password

  def follow other_user
    active_relationships.create followed_id: other_user.id
  end

  def unfollow other_user
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following? other_user
    following.include? other_user
  end

  def password_set?
    new_record? || password.present?
  end

  def User.digest value
    cost = BCrypt::Engine.cost
    cost = ActiveModel::SecurePassword.min_cost if BCrypt::Engine::MIN_COST
    BCrypt::Password.create value, cost: cost
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attributes remember_digest: nil
  end
end
