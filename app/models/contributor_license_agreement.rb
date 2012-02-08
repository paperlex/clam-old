class ContributorLicenseAgreement < ActiveRecord::Base
  belongs_to :user
  has_many :contracts
  has_many :signatures
  serialize :owner_responses
  
  def responses
    self.owner_responses
  end
  
end
