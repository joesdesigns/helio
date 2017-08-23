class Ancillary < ActiveRecord::Base
  belongs_to :license

  scope :eresource, -> { where(ancillary_type: 'accesscode') }
  scope :not_eresource, -> { where.not(ancillary_type: 'accesscode') } 

  def file_type
    self.ancillary_type == 'url' ? 'URL' : self.href.to_s.split('.').last.upcase
  end
end
