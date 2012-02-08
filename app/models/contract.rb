class Contract < ActiveRecord::Base
  serialize :responses
  
  belongs_to :user
  belongs_to :contributor_license_agreement
  has_one :signature
  
end
