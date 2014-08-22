# encoding: utf-8

class Mailing < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :user

  has_many :restrictionizations
  has_many :restrictions, through: :restrictionizations

  has_many :comments

  attr_accessible :approach, :description, :folder, :layout, :objective, :periodicity, :sms, :typemailing, :restriction_ids, :rlowner_id, :status

  validates_presence_of :approach, :description, :folder, :layout, :objective, :typemailing, :restriction_ids

  validates_length_of :sms, :maximum => 160, :too_long => 'tem que ter no máximo 160 caracteres'

  extend FriendlyId
  friendly_id :objective, use: :slugged

  def normalize_friendly_id(input)

  	ret =  input.to_s[0..30].strip
 
 	#blow away apostrophes
    ret.gsub! /['`]/,""

    # @ --> at, and & --> and
    ret.gsub! /\s*@\s*/, " at "
    ret.gsub! /\s*&\s*/, " and "

    #replace all non alphanumeric, underscore or periods with underscore
     ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '-'  

     #convert double underscores to single
     ret.gsub! /_+/,"-"

     #strip off leading/trailing underscore
     ret.gsub! /\A[_\.]+|[_\.]+\z/,""

     ret

  end

end
