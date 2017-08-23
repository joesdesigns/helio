class License < ActiveRecord::Base
  belongs_to :user
  belongs_to :book
  has_many :ancillaries, :dependent => :destroy
end
