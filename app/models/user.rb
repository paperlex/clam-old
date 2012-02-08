class User < ActiveRecord::Base
  has_many :contributor_license_agreements
  has_many :signatures
  has_many :contracts
  
  def self.find_or_create_by_github_id_and_github_login(id, login)
    user = (find_by_github_id(id.to_s) || create(:github_id => id.to_s))
    user.update_attribute :github_login, login
    user
  end
  
  def update_email(value)
    if self.github_email != value
      self.update_attribute :github_email, value
    end
  end
  
end
