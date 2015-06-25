class User < ActiveRecord::Base
  before_create :create_activation_digest
  attr_accessor :activation_token, :reset_token, :remember_token

  has_many :lessons, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                  foreign_key: "followed_id",
                                  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower,
                       dependent: :destroy

  validates :name, presence: true, length: {maximum: Settings.length.short_maximum}
  validates :email, presence: true, length: {maximum: Settings.length.long_maximum},
                    format: {with: Settings.VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false},
                    if: "new_record?"
  validates :password, length: {minimum: Settings.length.minimum}, if: "password_set?"

  has_secure_password

  def password_set?
    new_record? || password.present?
  end

  def User.digest value
    cost = BCrypt::Engine.cost
    cost = ActiveModel::SecurePassword.min_cost if BCrypt::Engine::MIN_COST
    BCrypt::Password.create value, cost: cost
  end

  def User.digest string
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    BCrypt::Password.create string, cost: cost
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def activate
    update_attributes active: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def remember
    self.remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password? token
    end

  def forget
    update_attributes remember_digest: nil
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.TWOHOUR.hours.ago
  end
end
