class Book < ActiveRecord::Base
  has_many :licenses
  has_many :ancillaries, :through => :licenses
  has_many :users, :through => :licenses
end
