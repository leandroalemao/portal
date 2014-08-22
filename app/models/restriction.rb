class Restriction < ActiveRecord::Base

  has_many :restrictionizations
  has_many :mailings, through: :restrictionizations

  attr_accessible :name
  
end
