class User < ActiveRecord::Base
  has_many :filters
  has_many :messages

  attr_accessible :username, :password, :password_confirmation

  attr_accessor :password
  before_create :set_role
  before_save :prepare_password

  ROLES = %w(god admin member)

  def self.authenticate(login, pass)
    user = find_by_username(login)
    return user if user && user.password_hash == user.encrypt_password(pass)
  end

  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end

  def role?( role ); roles.include? role.to_s end
  def roles; ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? } end
  def roles=(r); self.roles_mask = (r & ROLES).map{|e| 2**ROLES.index(e)}.sum end
  def to_s; username end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end

  def set_role; self.roles = ["member"] if self.roles.empty? end
end



# == Schema Information
#
# Table name: users
#
#  id            :integer(4)      not null, primary key
#  password_hash :string(255)
#  password_salt :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  username      :string(255)
#  roles_mask    :integer(4)
#

