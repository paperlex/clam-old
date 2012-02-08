class Signature < ActiveRecord::Base
  belongs_to :user
  belongs_to :contract
  belongs_to :contributor_license_agreement
  
end
