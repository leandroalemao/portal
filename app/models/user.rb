class User < ActiveRecord::Base

  has_many :tickets

  has_many :mailings

  has_many :comments

  #after_create :send_welcome_email 

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
if Rails.env.production?
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
else
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :registerable 
end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :role, :name, :branch, :phone
  # attr_accessible :title, :body
  validates_presence_of :username, :role, :name, :branch, :phone
  validates :username, :uniqueness => true,
          :length => { :within => 4..12 }



  def self.find_for_database_authentication(conditions={})
  	self.where("username = ?", conditions[:username]).limit(1).first 
  end

  def username_name
      User.try(:name)
  end

  def username_name=(name)
      self.user = User.find_or_create_by_name(name) if name.present?
  end

  def display_name
    "#{self.name} - (#{self.username})"
  end


   #private

  #def send_welcome_email
  #    user = User.find_by_email(self.email)
  #    UserMailer.signup_confirmation(user).deliver
 #end

end
