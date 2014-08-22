class Comment < ActiveRecord::Base

  belongs_to :user

  belongs_to :mailing

  attr_accessible :description, :name

  #validates_presence_of :description
  
end
