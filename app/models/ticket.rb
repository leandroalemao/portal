class Ticket < ActiveRecord::Base

  belongs_to :user

  attr_accessible :descricao, :nome, :responsavel

  validates_presence_of :nome, :descricao

  extend FriendlyId
  friendly_id :nome, use: :slugged

end
